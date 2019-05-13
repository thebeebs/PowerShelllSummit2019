# Variables
$s3BucketName = ''
$serviceName = 'AWSKinesisTap'

# Download Kinesis Agent Configuration
Import-Module -Name 'AWSPowerShell'
$readS3Object = @{
    BucketName = $s3BucketName
    Key        = 'kinesis/detailed-appsettings.json'
    File       = "$env:ProgramFiles\Amazon\$serviceName\appsettings.json"
    Region     = 'us-east-2'
}
$null = Read-S3Object @readS3Object

# Show the Kinesis Log to demonstrate auto-loading of the configuration
$getContent = @{
    Path = "C:\ProgramData\Amazon\$serviceName\Logs\KinesisTap.log"
    Wait = $true
    Tail = 50
}
Get-Content @getContent
