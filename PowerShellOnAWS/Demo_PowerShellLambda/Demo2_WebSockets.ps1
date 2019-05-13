<#
    Amazon API Gateway (a fully managed REST service) launched WebSocket support
    on 18 December, 2018, alongside a sample Node.js application.

    We're going to demo a port of that application to PowerShell Lambda Functions.

    Why is this important?
    To demonstrate that you'll find Serverless examples in many other languages doing
    all sorts of cool things in Serverless.

    ** You can also do those cool things with PowerShell! **

    Link:
    Node.JS: https://github.com/aws-samples/simple-websockets-chat-app
    PowerShell: https://github.com/austoonz/powershell-core-simple-websockets-chat-app
#>

$filePath = "$global:DemoRoot\Demo_PowerShellLambda"
Set-Location -Path $filePath

<#
    Look at the Github Repository
#>
Start-Process https://github.com/austoonz/powershell-core-simple-websockets-chat-app.git

<#
    Clone the PowerShell Core Port of simple-websockets-chat-app
#>
git clone https://github.com/austoonz/powershell-core-simple-websockets-chat-app.git
Set-Location -Path "$filePath\powershell-core-simple-websockets-chat-app"

<#
    Follow the instructions listed in the README.md
#>
Import-Module -Name 'AWSLambdaPSCore'

$functionScript = [System.IO.Path]::Combine('.', 'WebSocket', 'WebSocket.ps1')
$websocketManifest = [System.IO.Path]::Combine('.', 'WebSocket', 'WebSocket.psd1')
$lambdaPackage = [System.IO.Path]::Combine('.', '_packaged', 'WebSocket.zip')

Import-Module $websocketManifest

$null = New-AWSPowerShellLambdaPackage -ScriptPath $functionScript -OutputPackage $lambdaPackage

dotnet lambda deploy-serverless 'DemoWebsockets' --template template.yaml --region $awsRegion --s3-bucket $global:s3BucketName

# Connect to the Websocket Uri

# Send a message
<#

{"action":"sendmessage", "data":"Hello World from PowerShell Lambda!"}

#>

