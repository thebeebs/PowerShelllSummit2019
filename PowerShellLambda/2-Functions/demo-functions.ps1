Set-Location -Path "$global:demoroot\2-Functions\"

<#
    Create a Basic Lambda Function as a script
#>
$functionName = 'demo-functions'
code ".\$functionName\$functionName.ps1"

<#
    Retrieve the IAM Role to prevent prompt
#>
$iamRoleName = 'DemoLambdaIAM'
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
    Payload      = ConvertTo-Json -InputObject @{name = 'PSConfEu'}
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