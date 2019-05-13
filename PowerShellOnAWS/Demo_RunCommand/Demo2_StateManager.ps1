<#
    State Manager allows you to schedule Run Command executions against managed
    instances.

    A Managed Instance can be any Amazon EC2 Instance, or an on-premises machine
    configured for AWS Systems Manager.

    State Manager does not require inbound access, the managed instance creates
    outbound connections to the AWS Systems Manager service.

    Can target executions against managed instances or tags.
#>

$filePath = "$global:DemoRoot\Demo_RunCommand"
Set-Location -Path $filePath

# Enabled PowerShell ScriptBlock Logging
$powershellScript = {
    $regSplat = @{
        Path  = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
        Force = $true
    }
    $null = New-Item @regSplat -ItemType 'Directory'
    $null = Set-ItemProperty @regSplat -Name 'EnableScriptBlockLogging' -Value '1'
    $null = Set-ItemProperty @regSplat -Name 'EnableScriptBlockInvocationLogging' -Value '1'
}

$commands = ($powershellScript | Out-String) -split "\r\n"

$associationName = 'StateManagerDemo'

$associationId = (Get-SSMAssociationList | Where-Object {$_.AssociationName -eq $associationName}).AssociationId
if ($associationId) {Remove-SSMAssociation -Name $associationName -AssociationId $associationId -Force}

$newSSMAssociation = @{
    AssociationName = $associationName

    # For reference, this is "DocumentName" on Send-SSMCommand
    Name = 'AWS-RunPowerShellScript'
    Target = @(
        @{
            Key = 'tag:Name'
            Values = @( 'DSCDemo' )
        }
    )
    Parameter = @{
        commands = $commands
    }
    MaxConcurrency = 2
    MaxError = 1
    ScheduleExpression = 'cron(0/30 * * * ? *)'
}
New-SSMAssociation @newSSMAssociation

# Retrieve the status of an Association
Get-SSMAssociationExecution -AssociationId $associationId
$associationId = (Get-SSMAssociationList | Where-Object {$_.AssociationName -eq $associationName}).AssociationId

# Remove the Association
Remove-SSMAssociation -Name $associationName -AssociationId $associationId -Force
