$filePath = "$global:DemoRoot\Demo_SecretsManager"
Set-Location -Path $filePath

function Save-SECCredential
{
    param
    (
        [String] $Name,
        [PSCredential] $Credential,
        [String] $Region
    )

    try
    {
        $null = Update-SECSecret -SecretId $Name -Region $Region -SecretString (ConvertTo-Json -InputObject @{
                Username = $Credential.UserName
                Password = $Credential.GetNetworkCredential().Password
            })
    }
    catch
    {
        $null = New-SECSecret -Name $Name -Region $Region -SecretString (ConvertTo-Json -InputObject @{
                Username = $Credential.UserName
                Password = $Credential.GetNetworkCredential().Password
            })
    }
}

function Get-SECCredential
{
    param
    (
        [String] $Name,
        [String] $Region
    )

    $splat = @{
        SecretId = $Name
        Region   = $Region
    }
    $ss = StringToSecureString -String ((Get-SECSecretValue @splat).SecretString)
    $bstr = SecureStringToBSTR -SecureString $ss

    [PSCredential]::new(
        (ConvertFrom-Json -InputObject (PtrToStringAuto -BSTR $bstr)).Username,
        (StringToSecureString -String (ConvertFrom-Json -InputObject (PtrToStringAuto -BSTR $bstr)).Password)
    )
}

<#
    Private Functions
#>
function SecureStringToBSTR
{
    param
    (
        [SecureString] $SecureString
    )
    [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
}

function PtrToStringAuto
{
    param
    (
        [IntPtr] $BSTR
    )

    [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

function StringToSecureString
{
    param
    (
        [String] $String
    )
    $ss = ConvertTo-SecureString -String $String -AsPlainText -Force
    Remove-Variable -Name String
    $ss
}
