$filePath = "$global:demoroot\2-S3Events\2_SNS-SQS-Lambda"
Set-Location -Path $filePath

<#
    AWS Lambda Templates (/Blueprints)
#>
Get-AWSPowerShellLambdaTemplate

<#
    Create a new Lambda Function from the S3EventToSNSToSQS blueprint
#>
$functionName = 'PoshSummitsS3EventFanout'
New-AWSPowerShellLambda -Template S3EventToSNSToSQS -ScriptName $functionName

<#
    Create a PowerShell Lambda Artifact and deploy from S3
#>
$null = New-AWSPowerShellLambdaPackage -ScriptPath ".\$functionName\$functionName.ps1" -OutputPackage ".\$functionName\$functionName.zip"

<#
    Use the AWS CLI to package and deploy the CloudFormation Template
#>
& aws cloudformation package --template-file serverless.yml --s3-bucket $global:s3BucketName --output-template-file updated.yml --region us-west-2
& aws cloudformation deploy --template-file updated.yml --stack-name $functionName --capabilities CAPABILITY_IAM --parameter-overrides BucketNamePrefix=s3events-pshsummit-demo2019 --region us-west-2

$outputs = (Get-CFNStack -StackName $functionName).Outputs
$bucketName = $outputs.Where({$_.OutputKey -eq 'BucketName'}).OutputValue
$lambdaFunctionOne = $outputs.Where({$_.OutputKey -eq 'LambdaFunctionOne'}).OutputValue
$lambdaFunctionTwo = $outputs.Where({$_.OutputKey -eq 'LambdaFunctionTwo'}).OutputValue

<#
    Create an S3 Object
#>
$dateStamp = [DateTime]::UtcNow
Write-Host 'Start DateStamp:' $dateStamp
$null = Write-S3Object -BucketName $bucketName -Content 'Hello PowerShell Summit!' -Key 'HelloPowerShellSummit.txt'

<#
    Read Lambda Logs: Fanout Function One
#>
$logGroupName = "/aws/lambda/$lambdaFunctionOne"
Write-Host 'LogGroupName:' $logGroupName
$logEvents = foreach ($logStream in (Get-CWLLogStream -LogGroup $logGroupName))
{
    Get-CWLLogEvent -LogGroupName $logGroupName -LogStreamName $logStream.LogStreamName -StartTime $dateStamp | ForEach-Object {$_.Events}
}
$logEvents | Select-Object Message, Timestamp | Format-Table -AutoSize

<#
    Read Lambda Logs: Fanout Function Two
#>
$logGroupName = "/aws/lambda/$lambdaFunctionTwo"
Write-Host 'LogGroupName:' $logGroupName
$logEvents = foreach ($logStream in (Get-CWLLogStream -LogGroup $logGroupName))
{
    Get-CWLLogEvent -LogGroupName $logGroupName -LogStreamName $logStream.LogStreamName -StartTime $dateStamp | ForEach-Object {$_.Events}
}
$logEvents | Select-Object Message, Timestamp | Format-Table -AutoSize

<#
    Trigger a number of times
#>
0..50 | ForEach-Object {
    $null = Write-S3Object -BucketName $bucketName -Content "Hello PowerShell Summit... $_!" -Key "HelloPowerShellSummit_$_.txt"
}

<#
    Get the logs
#>
$logEvents = foreach ($logStream in (Get-CWLLogStream -LogGroup $logGroupName))
{
    Get-CWLLogEvent -LogGroupName $logGroupName -LogStreamName $logStream.LogStreamName -StartTime $dateStamp | ForEach-Object {$_.Events}
}
$logEvents | Where-Object {$_.Message -like '*Object*is*bytes*'} | Select-Object Message, Timestamp | Format-Table -AutoSize

<#
    Cleanup
#>
Get-Item -Path "$filePath\$functionName" | Remove-Item -Recurse -Force
Get-Item -Path "$filePath\updated.yml" | Remove-Item -Recurse -Force
Get-S3Object -BucketName $bucketName | ForEach-Object {
    $null = Remove-S3Object -BucketName $bucketName -Key $_.Key -Force
}
Remove-CFNStack -StackName $functionName -Force
