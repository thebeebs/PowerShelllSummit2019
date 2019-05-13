$outputs = (Get-CFNStack -StackName 'PSModuleTranslation').Outputs
$uri = $outputs.Where({$_.OutputKey -eq 'APIEndpoint'}).OutputValue
Write-Host "`nURI: $uri"

<#
    Language Codes deployed:
    French:   fr
    German:   de
    Italiasn: it
    Japanese: ja
    Spanish:  es
#>

# Get a single module
Invoke-RestMethod -Method Get -Uri "$uri/get/fr/awspowershell"
(Invoke-RestMethod -Method Get -Uri "$uri/get/ja/awslambdapscore").Description

# Get all modules for a language
(Invoke-RestMethod -Method Get -Uri "$uri/get/fr").Count
(Invoke-RestMethod -Method Get -Uri "$uri/get/fr") | Select-Object -First 10 | Select-Object Name, Description

# Find a word in a languages descriptions
Invoke-RestMethod -Method Get -Uri "$uri/find/fr/permettent"
