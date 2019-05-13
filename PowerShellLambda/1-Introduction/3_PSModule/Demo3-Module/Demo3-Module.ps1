<#

Process for finding the modules:

1. Is the module in memory?
(Get-Module -Name <>)

2. Can the module be found locally?
(Get-Module -Name <> -ListAvailable)

3. Can the module be found in a repository?
(Find-Module -Name <>)

4. (/optional) Can the module be found in a specified repository?
(Find-Module -Name <> -Repository <>)

#>

#Requires -Modules @{ModuleName='PoshSummitModule';ModuleVersion='1.0'}
