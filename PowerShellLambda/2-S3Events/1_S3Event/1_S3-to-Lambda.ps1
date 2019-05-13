$filePath = "$global:demoroot\2-S3Events\1_S3Event"
Set-Location -Path $filePath

<#
    AWS Lambda Templates (/Blueprints)
#>
Get-AWSPowerShellLambdaTemplate

<#
    Create a new Lambda Function from the S3Event blueprint
#>
$functionName = 'Demo-S3Event'
New-AWSPowerShellLambda -Template S3Event -ScriptName $functionName

<#
    Retrieve the IAM Role to prevent prompt
#>
$iamRoleName = 'PoshSummit2019'
$iamRoleArn = (Get-IAMRole -RoleName $iamRoleName).Arn

<#
    Create a PowerShell Lambda Artifact and deploy from S3
#>
$zipfile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "$functionName.zip")
$package = New-AWSPowerShellLambdaPackage -ScriptPath ".\$functionName\$functionName.ps1" -OutputPackage $zipfile

$s3Hash = @{
    BucketName = $global:s3BucketName
    Key        = $functionName
}
Write-S3Object @s3Hash -File $zipfile

$publishLMFunction = @{
    FunctionName = $functionName
    Handler      = $package.LambdaHandler
    Runtime      = 'dotnetcore2.1'
    Role         = $iamRoleArn
    MemorySize   = 512
    Timeout      = 30
    Publish      = $true
}
$lambda = Publish-LMFunction @publishLMFunction @s3Hash

<#
    Create an S3 Bucket
#>
$triggerBucketName = ('powershellsummit2019-s3event-{0}' -f [Guid]::NewGuid().Guid).Substring(0, 60)
$null = New-S3Bucket -BucketName $triggerBucketName

<#
    Add permission for the Bucket to trigger the Lambda Function

    "ARN" = Amazon Resource Name. Unique name for a resources across all of AWS
#>
$addLMPermission = @{
    StatementId  = $triggerBucketName
    Principal    = 's3.amazonaws.com'
    SourceArn    = "arn:aws:s3:::$triggerBucketName"
    Action       = 'lambda:InvokeFunction'
    FunctionName = $functionName
}
Add-LMPermission @addLMPermission

<#
    Add an S3 Bucket Trigger to Invoke the Lambda Function
#>
$lambdaConfiguration = [Amazon.S3.Model.LambdaFunctionConfiguration]::new()
$lambdaConfiguration.Events = [Amazon.S3.EventType]::ObjectCreatedPut
$lambdaConfiguration.FunctionArn = $lambda.FunctionArn
Write-S3BucketNotification -BucketName $triggerBucketName -LambdaFunctionConfiguration $lambdaConfiguration

<#
    Write an object to my S3 Bucket
#>
$dateStamp = Get-Date
$writeS3ObjectSplat = @{
    BucketName = $triggerBucketName
    Key = 'HelloPowerShellSummit.txt'
    Content = 'Hello PowerShell Summit!'
}
Write-S3Object @writeS3ObjectSplat

<#
    Read Lambda Logs
#>
$logGroupName = "/aws/lambda/$functionName"
foreach ($logStream in (Get-CWLLogStream -LogGroup $logGroupName))
{
    Get-CWLLogEvent -LogGroupName $logGroupName -LogStreamName $logStream.LogStreamName -StartTime $dateStamp | ForEach-Object {$_.Events | Select-Object Message}
}

<#
    Cleanup
#>
$null = Remove-LMPermission -FunctionName $functionName -StatementId $triggerBucketName -Force
$null = Remove-LMFunction -FunctionName $functionName -Force
$null = Remove-CWLLogGroup -LogGroupName "/aws/lambda/$functionName" -Force
$null = Get-S3Object -BucketName $triggerBucketName | ForEach-Object { Remove-S3Object -BucketName $_.BucketName -Key $_.Key -Force }
$null = Remove-S3Bucket -BucketName $triggerBucketName -Force
Get-Item -Path "$filePath\$functionName" | Remove-Item -Recurse -Force
