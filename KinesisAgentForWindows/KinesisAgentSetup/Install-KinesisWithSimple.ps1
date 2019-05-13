# Setup
$ProgressPreference = 'SilentlyContinue'
$s3BucketName = ''
$serviceName = 'AWSKinesisTap'

# Install Kinesis Agent
# https://docs.aws.amazon.com/kinesis-agent-windows/latest/userguide/getting-started.html#getting-started-installation
if (-not(Get-Service -Name $serviceName -ErrorAction 'SilentlyContinue')) {
    $s3 = 'https://s3-us-west-2.amazonaws.com'
    $url = "$s3/kinesis-agent-windows/downloads/InstallKinesisAgent.ps1"
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString($url))
}

# Download Kinesis Agent Configuration
Import-Module -Name 'AWSPowerShell'
$readS3Object = @{
    BucketName = $s3BucketName
    Key        = 'kinesis/simple-appsettings.json'
    File       = "$env:ProgramFiles\Amazon\$serviceName\appsettings.json"
    Region     = 'us-east-2'
}
$null = Read-S3Object @readS3Object

# Start the Kinesis Agent service
if ((Get-Service -Name $serviceName).Status -ne 'Running') {
    Start-Service -Name $serviceName
}

# Confirm the Kinesis Agent service is running
Get-Service -Name $serviceName
