if (Get-Module -Name 'AWSPowerShell.NetCore' -ListAvailable)
{
    Import-Module -Name 'AWSPowerShell.NetCore'
}
elseif (Get-Module -Name 'AWSPowerShell' -ListAvailable)
{
    Import-Module -Name 'AWSPowerShell'
}
else
{
    throw 'Please install an AWS PowerShell Module.'
}

# Deploy before talk
$global:DemoRoot = $PSScriptRoot
$cfnPath = "$global:DemoRoot\CloudFormation"
$awsRegion = 'us-east-1'
$awsProfileName = 'demo'
$guid = [Guid]::NewGuid().Guid
$global:s3BucketName = "$guid-$awsRegion"

Set-AWSCredential -ProfileName $awsProfileName
Set-DefaultAWSRegion -Region $awsRegion

# S3 Buckets
$random = $guid.split('-')[0]
$global:reportBucket = "dscdemo-report-bucket-$random"
$global:statusBucket = "dscdemo-status-bucket-$random"
$global:outputBucket = "dscdemo-ssmoutput-bucket-$random"

New-S3Bucket -BucketName $global:s3BucketName -Region $awsRegion
New-S3Bucket -BucketName $global:reportBucket -Region $awsRegion
New-S3Bucket -BucketName $global:statusBucket -Region $awsRegion
New-S3Bucket -BucketName $global:outputBucket -Region $awsRegion

Set-Location -Path $cfnPath

# Deploy the VPC
$stackName = 'VPC'
$zones = ((Get-EC2AvailabilityZone -Region $awsRegion).ZoneName | Select-Object -First 2) -join ','
dotnet lambda deploy-serverless $stackName --template vpc.yml --region $awsRegion --s3-bucket $global:s3BucketName --profile $awsProfileName --template-parameters AvailabilityZones="$zones"

# Deploy the DSC Demo SpotFleet
$stackName = 'AWSDSCDemoInstances'
dotnet lambda deploy-serverless $stackName --template ec2-spot-fleet.yml --region $awsRegion --s3-bucket $global:s3BucketName --profile $awsProfileName
