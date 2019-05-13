$filePath = "$global:DemoRoot\Demo_PowerShellLambda"
Set-Location -Path $filePath

<#
    Import the Module
#>
Import-Module -Name AWSLambdaPSCore

<#
    Look at the Commands
#>
Get-Command -Module AWSLambdaPSCore

<#
    AWS Lambda Templates (/Blueprints)
#>
Get-AWSPowerShellLambdaTemplate

<#
    Lets have a look
#>
$functionName = 'Demo1-HelloWorld'
New-AWSPowerShellLambda -Template Basic -ScriptName $functionName

<#
    Deploy the Lambda Function
#>
$publishAWSPowerShellLambdaSplat = @{
    Name = $functionName
    ScriptPath = ".\$functionName\$functionName.ps1"
}
Publish-AWSPowerShellLambda @publishAWSPowerShellLambdaSplat

<#
    Invoke the function

    Using "Convert" Module to help with MemoryStream response
#>
$response = Invoke-LMFunction -FunctionName $functionName
"`n$($response.Payload | ConvertTo-String)`n"

<#
    Cleanup
#>
Remove-LMFunction -FunctionName $functionName -Force
Remove-CWLLogGroup -LogGroupName "/aws/lambda/$functionName" -Force
Get-Item -Path "$filePath\$functionName" | Remove-Item -Force -Confirm:$false -Recurse

Clear-Host