# make-website-shortcut.ps1
# Creates a desktop shortcut "DeepSeek 官网" (blue-whale icon) that opens the
# DeepSeek official website. Region-aware:
#   domestic (CN) users      -> https://www.deepseek.com/    (zh-CN)
#   international (INT) users -> https://www.deepseek.com/en/ (en-US)
# Portable: all paths are derived from this script's own location at runtime.
# Usage:  powershell -NoProfile -ExecutionPolicy Bypass -File make-website-shortcut.ps1
#         optionally: -Region CN | INT | auto   (default: auto)
param(
  [ValidateSet('auto','CN','INT')]
  [string]$Region = 'auto'
)

$ErrorActionPreference = 'Stop'

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

# ---- region detection ----
# Primary signal: Windows "Home location" (GeoId 45 = mainland China).
# Fallback: system language (zh-*).
if ($Region -eq 'auto') {
  try {
    $geoId = (Get-WinHomeLocation).GeoId
    if ($geoId -eq 45) { $Region = 'CN' }
  } catch { }
  if ($Region -eq 'auto') {
    $Region = if ((Get-Culture).Name -match '^zh-') { 'CN' } else { 'INT' }
  }
}

# ---- target URL by region ----
$urlCN  = 'https://www.deepseek.com/'      # 国内官网 (zh-CN)
$urlINT = 'https://www.deepseek.com/en/'   # 国际官网 (en-US)
$url  = if ($Region -eq 'CN') { $urlCN } else { $urlINT }
$name = if ($Region -eq 'CN') { 'DeepSeek 官网' } else { 'DeepSeek Official' }
$desc = if ($Region -eq 'CN') { 'DeepSeek 官网' } else { 'DeepSeek official website' }

# ---- create the .lnk ----
$desktop = [Environment]::GetFolderPath('Desktop')
$lnkPath = Join-Path $desktop "$name.lnk"
$icon = Join-Path $here 'assets\whale-blue.ico'

$ws = New-Object -ComObject WScript.Shell
$lnk = $ws.CreateShortcut($lnkPath)
$lnk.TargetPath = $url
$lnk.IconLocation = $icon
$lnk.Description = $desc
$lnk.Save()

Write-Host "Shortcut created: $lnkPath"
Write-Host "Region: $Region  ->  $url"

