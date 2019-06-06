$filePath = "$global:demoroot\4-RDP\demo-rdp.ps1"
Set-Location -Path $filePath

<#
    Import the Module
#>
Import-Module -Name AWSLambdaPSCore

<#
    Lets have a look
#>
$functionName = 'demo-rdp'
New-AWSPowerShellLambda -Template 'Basic' -ScriptName $functionName


<#

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

#>

<#
    Retrieve the IAM Role to prevent prompt
#>
$iamRoleName = 'DemoLambdaIAM'
$iamRoleArn = (Get-IAMRole -RoleName $iamRoleName).Arn

<#
    Create a PowerShell Lambda Artifact and deploy from S3
#>
$zipfile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "$functionName.zip")
$package = New-AWSPowerShellLambdaPackage -ScriptPath ".\$functionName\$functionName.ps1" -OutputPackage $zipfile

$s3Hash = @{
    BucketName = $lambdaPackagesBucketName
    Key        = $functionName
}

Write-S3Object @s3Hash -File $zipfile

$publishLMFunction = @{
    FunctionName = $functionName
    Handler      = $package.LambdaHandler
    Runtime      = 'dotnetcore2.1'
    Role         = $iamRoleArn
    MemorySize   = 512
    Timeout      = 30
    Publish      = $true
}

Publish-LMFunction @publishLMFunction @s3Hash

<#
    Invoke the function

    Using "Convert" Module to help response MemoryStream conversion
#>
$response = Invoke-LMFunction -FunctionName $functionName
"`n$($response.Payload | ConvertTo-String)`n"

<#
    Cleanup
#>
Remove-LMFunction -FunctionName $functionName -Force
Remove-CWLLogGroup -LogGroupName "/aws/lambda/$functionName" -Force
Get-Item -Path "$filePath\$functionName" | Remove-Item -Force -Confirm:$false -Recurse

Clear-Host