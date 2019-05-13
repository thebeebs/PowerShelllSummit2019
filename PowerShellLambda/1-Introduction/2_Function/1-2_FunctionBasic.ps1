Set-Location -Path "$global:demoroot\1-Introduction\2_Function"

<#
    Create a Basic Lambda Function as a script
#>
$functionName = 'Demo2-Function'
code ".\$functionName\$functionName.ps1"

<#
    Retrieve the IAM Role to prevent prompt
#>
$iamRoleName = 'PoshSummit2019'
$iamRoleArn = (Get-IAMRole -RoleName $iamRoleName).Arn

<#
    Deploy the Lambda Function
#>
$publishAWSPowerShellLambdaSplat = @{
    Name                      = $functionName
    ScriptPath                = ".\$functionName\$functionName.ps1"
    PowerShellFunctionHandler = 'Invoke-Me'
    IAMRoleArn                = $iamRoleArn
}
Publish-AWSPowerShellLambda @publishAWSPowerShellLambdaSplat

<#
    Invoke the function

    Using "Convert" Module to help with Base64 Encoded and MemoryStream responses
#>
$invokeLMFunctionSplat = @{
    FunctionName = $functionName
    Payload      = ConvertTo-Json -InputObject @{name = 'PowerShell Summit'}
    LogType      = 'Tail'
}
$response = Invoke-LMFunction @invokeLMFunctionSplat
"`n$($response.LogResult | ConvertTo-String)`n"
"`n$($response.Payload | ConvertTo-String)`n"

<#
    Cleanup
#>
Remove-LMFunction -FunctionName $functionName -Force
Remove-CWLLogGroup -LogGroupName "/aws/lambda/$functionName" -Force
Get-Item -Path $zipfile | Remove-Item