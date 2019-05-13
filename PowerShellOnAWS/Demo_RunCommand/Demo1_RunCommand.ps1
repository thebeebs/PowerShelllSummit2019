<#
    Run Command allows you to execute "documents" against managed instances at scale
    to manage and configure your machines.

    A Managed Instance can be any Amazon EC2 Instance, or an on-premises machine
    configured for AWS Systems Manager.

    There are a number of public "documents" shipped by AWS, including:
      - AWS-RunShellScript
      - AWS-RunPowerShellScript
      - AWS-InstallMissingWindowsUpdates
      - AWSSupport-RunEC2RescueForWindowsTool
      - AWSEC2-CreateVssSnapshot

    Run Command does not require inbound access, the managed instance creates
    outbound connections to the AWS Systems Manager service.

    Can target executions against managed instances or tags.
#>

$filePath = "$global:DemoRoot\Demo_RunCommand"
Set-Location -Path $filePath

# Invoke a command against multiple EC2 Instances
$instanceIds = (Get-SSMInstanceInformation | Where-Object {
    $_.PlatformName -like '*Windows*'
}).InstanceId

$scriptBlock = {$PSVersionTable.PSVersion.ToString()}

$ssmCommandSplat = @{
    DocumentName = 'AWS-RunPowerShellScript'
    Parameter    = @{commands = $scriptBlock.ToString()}
    Target       = @{Key = 'instanceids'; Values = $instanceIds}
}
$commandId = Send-SSMCommand @ssmCommandSplat @awsAuth

# Retrieve the command status
Get-SSMCommandInvocation -CommandId $commandId.CommandId @awsAuth | Select-Object InstanceId,Status

# Retrieve the command output
(Get-SSMCommandInvocation -CommandId $commandId.CommandId @awsAuth -Detail $true).foreach({
    [PSCustomObject]@{
        InstanceId = $_.InstanceId
        PSVersion = $_.CommandPlugins.Output.Trim()
    }
})
