$filePath = "$global:DemoRoot\Demo_SecretsManager"
Set-Location -Path $filePath

$name = 'PoshCredential'
$region = 'us-east-1'

<#
    Create and save a new secret
#>
$Credential = Get-Credential
Save-SECCredential -Name $name -Credential $Credential -Region $region

<#
    Rerieve the secret value
#>
$retrieved = Get-SECCredential -Name $name -Region $region
$retrieved.GetType()
$retrieved

<#
    Remove the secret
#>
Remove-SECSecret -SecretId $name -DeleteWithNoRecovery $true -Force