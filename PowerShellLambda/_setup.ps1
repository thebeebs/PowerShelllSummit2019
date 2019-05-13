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
$awsRegion = 'us-west-2'

Set-Location -Path $global:demoroot

Import-Module -Name 'AWSPowerShell.NetCore','AWSLambdaPSCore'
Set-DefaultAWSRegion -Region $awsRegion

# Deploy pre-requisites before the talk:

# Demo Infrastructure: S3 -> SNS -> SQS -> LAMBDA
$filePath = "$global:demoroot\2-S3Events\2_SNS-SQS-Lambda"
Set-Location -Path $filePath

$functionName = 'PoshSummitsS3EventFanout'
New-AWSPowerShellLambda -Template S3EventToSNSToSQS -ScriptName $functionName

# Compile the PowerShell Lambda Functions
$null = New-AWSPowerShellLambdaPackage -ScriptPath "$filePath\$functionName\$functionName.ps1" -OutputPackage "$filePath\$functionName\$functionName.zip"

# Deploy
$stackName = $functionName
& aws cloudformation package --template-file serverless.yml --s3-bucket $global:s3BucketName --output-template-file updated.yml --region $awsRegion
& aws cloudformation deploy --template-file updated.yml --stack-name $stackName --capabilities CAPABILITY_IAM --parameter-overrides BucketNamePrefix=s3events-pshsummit-demo2019 --region $awsRegion
Remove-Item -Path (Join-Path -Path $filePath -ChildPath 'updated.yml')

# Demo Infrastructure: PS Module Translation
$filePath = "$global:demoroot\3-PSModuleTranslation"
Set-Location -Path $filePath

# Compile the PowerShell Lambda Functions
New-AWSPowerShellLambdaPackage -ScriptPath '.\Lambda\StartTranslationWorkflow.ps1' -OutputPackage '.\Packaged\StartTranslationWorkflow.zip'
New-AWSPowerShellLambdaPackage -ScriptPath '.\Lambda\PerformTranslation.ps1' -OutputPackage '.\Packaged\PerformTranslation.zip'
New-AWSPowerShellLambdaPackage -ScriptPath '.\Lambda\TranslateApi.ps1' -OutputPackage '.\Packaged\TranslateApi.zip'

# Deploy
$stackName = 'PSModuleTranslation'
aws cloudformation package --template-file serverless.yml --s3-bucket $global:s3BucketName --output-template-file updated.yml
aws cloudformation deploy --template-file updated.yml --stack-name $stackName --capabilities CAPABILITY_IAM --region $awsRegion
Remove-Item -Path (Join-Path -Path $filePath -ChildPath 'updated.yml')

Set-Location -Path $global:demoroot
