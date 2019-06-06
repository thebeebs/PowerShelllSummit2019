#Requires -Modules @{ModuleName='AWSPowerShell.NetCore';ModuleVersion='3.3.343.0'}

$rulesRemoved = 0

Get-EC2SecurityGroup | ForEach-Object -Process {

    $securityGroupId = $_.GroupId
    $_.IpPermission | ForEach-Object -Process {

        if($_.ToPort -eq 3389) {
            Write-Host "Found open RDP port for $securityGroupId"
            Revoke-EC2SecurityGroupIngress -GroupId $securityGroupId -IpPermission $_
            Write-Host "Removed open RDP port for $securityGroupId"
            $rulesRemoved++
        }
    }
}

Write-Host "Scan complete and removed $rulesRemoved EC2 security group ingress rules"