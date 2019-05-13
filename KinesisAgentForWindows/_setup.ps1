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
$global:demoroot = $PSScriptRoot
$global:s3BucketName = ''
$awsRegion = 'us-east-2'

# AWS Modules
Import-Module -Name 'AWSPowerShell.NetCore','AWSLambdaPSCore'
Set-DefaultAWSRegion -Region $awsRegion

# Deploy CloudFormation Stacks
$cfnFilePath = "$global:demoroot\CloudFormation"
Set-Location -Path $cfnFilePath

# Compile the Lambda Function
$functionName = 'PowerShellMetrics'
$zipPackage = [System.IO.Path]::Combine($filePath, ('{0}Package' -f $functionName), "$functionName.zip")
$null = New-AWSPowerShellLambdaPackage -ScriptPath "$filePath\$functionName\$functionName.ps1" -OutputPackage $zipPackage

# Deploy the Sink Resources
$stackName = 'KinesisSinkResources'
& aws cloudformation package --template-file sink-resources.yml --s3-bucket $global:s3BucketName --output-template-file updated.yml --region $awsRegion
& aws cloudformation deploy --template-file updated.yml --stack-name $stackName --capabilities CAPABILITY_NAMED_IAM --region $awsRegion
Remove-Item -Path updated.yml
Remove-Item -Path ([System.IO.Path]::Combine($filePath, ('{0}Package' -f $functionName))) -Force -Recurse

# Deploy the EC2 Instances
$stackName = 'KinesisDemoSpotFleet'
& aws cloudformation deploy --template-file ec2-spot-fleet.yml --stack-name $stackName --capabilities CAPABILITY_NAMED_IAM --region $awsRegion

Set-Location -Path $global:demoroot
