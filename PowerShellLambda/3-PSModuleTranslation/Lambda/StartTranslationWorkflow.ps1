#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.498.0'}
#Requires -Modules @{ModuleName='PackageManagement';ModuleVersion='1.2.3'}
#Requires -Modules @{ModuleName='PowerShellGet';ModuleVersion='2.0.4'}

Write-Host ('Using SNS Topic: {0}' -f $env:SNSTopicArn)

$prefix = $LambdaInput.Prefix
$galleryModules = Find-Module -Name "$prefix*" -Repository 'PSGallery'

# Foreach Module, publish an SNS Message with Name and Description
foreach ($module in $galleryModules)
{
    $record = ConvertTo-Json -Compress -InputObject @{
        name        = $module.Name
        description = $module.Description
        version     = $module.Version
    }
    $null = Publish-SNSMessage -Message $record -TopicArn $env:SNSTopicArn
}

Write-Host ('Published {0} messages to SNS' -f $galleryModules.Count)
