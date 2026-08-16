# make-shortcut.ps1
# Creates a desktop shortcut "DeepSeek Harness" that launches launcher.ps1
# hidden, using the black-whale icon from assets\harness.ico.
# Portable: all paths are derived from this script's own location at runtime.
$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$ws = New-Object -ComObject WScript.Shell
$desktop = [Environment]::GetFolderPath('Desktop')
$lnkPath = Join-Path $desktop 'DeepSeek Harness.lnk'

$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = 'powershell.exe'
$lnk.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$here\launcher.ps1`""
$lnk.WorkingDirectory = $here
$lnk.IconLocation = "$here\assets\harness.ico"
$lnk.Description = 'Open DeepSeek Harness web UI'
$lnk.Save()

Write-Host "Shortcut created: $lnkPath"
