<#
    AWS Secrets Manager

    Helps you protect secrets needed to access your applications, services and IT resources.
    Allows you to easily rotate, manage and retrieve database credentials, API keys, and other
    secrets throughout their lifecycle.

    Integrates with services such as Amazon RDS and can rotate database credentials on your behalf,
    automatically.

    Can also trigger custom rotation Lambda functions so you can write your own code to handle the
    rotation of a secret.
#>

$filePath = "$global:DemoRoot\Demo_SecretsManager"
Set-Location -Path $filePath

# Secret Name
$name = 'PoshDemo'

<#
    Generate a new secret
#>
$secretString = Get-SECRandomPassword -ExcludeCharacter '%=@'
$secretString

<#
    Create and save a new secret
#>
New-SECSecret -Name $name -SecretString $secretString -Description 'PowerShell Summit Demo'

<#
    Rerieve the secret value
#>
(Get-SECSecretValue -SecretId $Name).SecretString

<#
    Update the secret
#>
Update-SECSecret -SecretId $name -SecretString 'My new secret value...'

<#
    Rerieve the secret value
#>
(Get-SECSecretValue -SecretId $Name).SecretString

<#
    Remove the secret
#>
Remove-SECSecret -SecretId $name -DeleteWithNoRecovery $true -Force