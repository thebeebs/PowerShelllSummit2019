$moduleRoot = "$global:demoroot\1-Introduction\3_PSModule"
Set-Location -Path $moduleRoot

<#
    Create a Basic Lambda Function using a Module
#>
$functionName = 'Demo3-Module'
code "$moduleRoot\$functionName\Module\PoshSummitModule.psd1"
code "$moduleRoot\$functionName\Module\PoshSummitModule.psm1"
code "$moduleRoot\$functionName\$functionName.ps1"

<#
    Retrieve the IAM Role to prevent prompt
#>
$iamRoleName = 'PoshSummit2019'
$iamRoleArn = (Get-IAMRole -RoleName $iamRoleName).Arn

<#
    Import the module so the AWS Lambda tooling can find it
#>
Get-Module -Name PoshSummitModule | Remove-Module
Import-Module "$moduleRoot\$functionName\Module\PoshSummitModule.psd1" -Force
(Get-Module -Name PoshSummitModule).Path

<#
    Create a PowerShell Lambda Artifact and deploy from S3
#>
$zipfile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "$functionName.zip")
$package = New-AWSPowerShellLambdaPackage -ScriptPath ".\$functionName\$functionName.ps1" -OutputPackage $zipfile

$s3Hash = @{
    BucketName = $global:s3BucketName
    Key = $functionName
}
Write-S3Object @s3Hash -File $zipfile -Region 'us-west-2'

$publishLMFunction = @{
    FunctionName         = $functionName
    Handler              = $package.LambdaHandler
    Runtime              = 'dotnetcore2.1'
    Role                 = $iamRoleArn
    MemorySize           = 512
    Timeout              = 30
    Environment_Variable = @{
        AWS_POWERSHELL_FUNCTION_HANDLER = 'Invoke-ModuleFunction'
        BUCKET_NAME = $global:s3BucketName
    }
    Publish              = $true
}
$null = Publish-LMFunction @publishLMFunction @s3Hash

<#
    Invoke the function

    Using "Convert" Module to help with MemoryStream response
#>
$invokeLMFunctionSplat = @{
    FunctionName = $functionName
    Payload = ConvertTo-Json -InputObject @{name = 'PowerShell Summit'}
    LogType = 'Tail'
}
$response = Invoke-LMFunction @invokeLMFunctionSplat
"`n$($response.LogResult | ConvertTo-String)`n"
"`n$($response.Payload | ConvertTo-String)`n"

<#
    Cleanup
#>
Remove-Module -Name 'PoshSummitModule'
Remove-LMFunction -FunctionName $functionName -Force
Remove-CWLLogGroup -LogGroupName "/aws/lambda/$functionName" -Force
