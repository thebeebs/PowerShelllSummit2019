# Import Modules
Import-Module -Name 'AWSPowerShell'

# Variables
$ProgressPreference = 'SilentlyContinue'
$s3BucketName = ''
$serviceName = 'AWSKinesisTap'

# Enabled PowerShell ScriptBlock Logging
$regSplat = @{
    Path  = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
    Force = $true
}
$null = New-Item @regSplat -ItemType 'Directory'
$null = Set-ItemProperty @regSplat -Name 'EnableScriptBlockLogging' -Value '1'
$null = Set-ItemProperty @regSplat -Name 'EnableScriptBlockInvocationLogging' -Value '1'

# Install Kinesis Agent
# https://docs.aws.amazon.com/kinesis-agent-windows/latest/userguide/getting-started.html#getting-started-installation
if (-not(Get-Service -Name $serviceName -ErrorAction 'SilentlyContinue'))
{
    $url = 'https://s3-us-west-2.amazonaws.com/kinesis-agent-windows/downloads/InstallKinesisAgent.ps1'
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url))
}

# Download Kinesis Agent Configuration
$readS3Object = @{
    BucketName = $s3BucketName
    Key        = 'kinesis/detailed-appsettings.json'
    File       = "$env:ProgramFiles\Amazon\$serviceName\appsettings.json"
    Region     = 'us-east-2'
}
$null = Read-S3Object @readS3Object

# Start the Kinesis Agent Service
if ((Get-Service -Name $serviceName).Status -ne 'Running') {
    Start-Service -Name $serviceName
}
