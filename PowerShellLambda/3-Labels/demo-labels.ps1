$filePath = "$global:demoroot\3-Labels\demo_labels"
Set-Location -Path $filePath

<#
    Import the Module
#>
Import-Module -Name AWSLambdaPSCore

<#
    Retrieve the IAM Role to prevent prompt
#>
$iamRoleName = 'DemoLambdaIAM'
$iamRoleArn = (Get-IAMRole -RoleName $iamRoleName).Arn


<#
    Lets have a look
#>
$functionName = 'demo-labels'
New-AWSPowerShellLambda -Template 'DetectLabels' -ScriptName $functionName

<#
    Create a PowerShell Lambda Artifact and deploy from S3
#>
$zipfile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "$functionName.zip")
$package = New-AWSPowerShellLambdaPackage -ScriptPath ".\$functionName\$functionName.ps1" -OutputPackage $zipfile

$s3Hash = @{
    BucketName = $lambdaPackagesBucketName
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
Publish-LMFunction @publishLMFunction @s3Hash

<#
    Cleanup
#>
$null = Remove-LMPermission -FunctionName $functionName -StatementId $triggerBucketName -Force
$null = Remove-LMFunction -FunctionName $functionName -Force
$null = Remove-CWLLogGroup -LogGroupName "/aws/lambda/$functionName" -Force
$null = Get-S3Object -BucketName $triggerBucketName | ForEach-Object { Remove-S3Object -BucketName $_.BucketName -Key $_.Key -Force }
$null = Remove-S3Bucket -BucketName $triggerBucketName -Force
$null = Get-S3Object -BucketName $lambdaPackagesBucketName | ForEach-Object { Remove-S3Object -BucketName $_.BucketName -Key $_.Key -Force }
$null = Remove-S3Bucket -BucketName $lambdaPackagesBucketName -Force
Get-Item -Path "$filePath\$functionName" | Remove-Item -Recurse -Force
