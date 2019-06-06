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

<#
    Configure default variables:

    $global:demoroot -> used to provide the root path for all script executions
    $global:s3BucketName -> used for CloudFormation Deployments and other S3 artifact requirements
    $awsRegion -> the AWS Region for deployments
#>
$global:demoroot = 'C:\GitHub\PowerShelllSummit2019\PowerShellLambda'
$global:s3BucketName = ''
$awsRegion = 'us-west-2' #Oregon

Set-Location -Path $global:demoroot

Import-Module -Name 'AWSPowerShell.NetCore','AWSLambdaPSCore'
Set-DefaultAWSRegion -Region $awsRegion

# Deploy pre-requisites before the talk:
Set-Location -Path $global:demoroot

<#
    Create an S3 Bucket to deploy code to 
#>
$lambdaPackagesBucketName = ('demo-lambda-package-{0}' -f [Guid]::NewGuid().Guid).Substring(0, 60)
$null = New-S3Bucket -BucketName $lambdaPackagesBucketName
$global:s3BucketName = $lambdaPackagesBucketName
