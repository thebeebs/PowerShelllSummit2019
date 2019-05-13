# Enable ScriptBlock Logging
$path = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
$null = New-Item -Path $path -ItemType 'Directory' -Force
$null = Set-ItemProperty -Path $path -Name 'EnableScriptBlockLogging' -Value '1' -Force
$null = Set-ItemProperty -Path $path -Name 'EnableScriptBlockInvocationLogging' -Value '1' -Force
