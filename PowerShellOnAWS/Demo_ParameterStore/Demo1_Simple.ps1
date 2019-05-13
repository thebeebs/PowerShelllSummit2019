<#
    AWS Systems Manager Parameter Store:

    Secure, hierarchical storage for configuration data and secrets.

    Support for String, StringList or SecureString.
#>

$filePath = "$global:DemoRoot\Demo_ParameterStore"
Set-Location -Path $filePath

$splat = @{
    Name        = '/MyService/Production/configValue'
    Value       = 'PROD-1234567890'
    Description = 'Config Value for Production'
    Type        = 'String'
    Overwrite   = $true
}
Write-SSMParameter @splat

$splat = @{
    Name        = '/MyService/Test/configValue'
    Value       = 'TEST-0987654321'
    Description = 'Config Value for Test'
    Type        = 'String'
    Overwrite   = $true
}
Write-SSMParameter @splat

$splat = @{
    Name        = '/MyService/Production/secretCode'
    Value       = 'MySuperSecretValue'
    Description = 'A Secure String Value'
    Type        = 'SecureString'
    Overwrite   = $true
}
Write-SSMParameter @splat

$splat = @{
    Name        = '/MyService/Test/secretCode'
    Value       = 'ThisIsAnotherSecretValue'
    Description = 'A Secure String Value'
    Type        = 'SecureString'
    Overwrite   = $true
}
Write-SSMParameter @splat

$splat = @{
    Name        = 'SecureStringDemo'
    Value       = ConvertTo-Json -Compress -InputObject @{
        RichObject = 'Yes it is!'
    }
    Description = 'A Secure String Value'
    Type        = 'SecureString'
    Overwrite   = $true
}
Write-SSMParameter @splat

<#
    Rerieve the parameters by path
#>
Get-SSMParametersByPath -Path '/MyService/Production' | Select-Object Name, Type, Value

<#
    Retrieve parameter values
#>
# Single Parameter
(Get-SSMParameterValue -Name '/MyService/Production/configValue').Parameters[0].Value

# Multiple Parameters
(Get-SSMParametersByPath -Path '/MyService/Production' | Get-SSMParameterValue).Parameters | Select-Object Name, Value

# Multiple Parameters with Decryption
(Get-SSMParametersByPath -Path '/MyService/Production' | Get-SSMParameterValue -WithDecryption $true).Parameters | Select-Object Name, Value

<#
    Remove the parameters
#>
Get-SSMParametersByPath -Path '/MyService/Production' | Remove-SSMParameter -Force
Get-SSMParametersByPath -Path '/MyService/Test' | Remove-SSMParameter -Force
