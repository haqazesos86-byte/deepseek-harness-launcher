# launcher.ps1
# Double-click launcher for DeepSeek Harness web UI.
# Behavior:
#   1) If the server is already running on :3080 -> just open the browser.
#   2) Otherwise start dsh web hidden, wait until it is ready, then open the browser.
$ErrorActionPreference = 'Stop'
$url = 'http://127.0.0.1:3080/'
$timeoutSec = 120

function Test-Server {
    try {
        $resp = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 2
        return ($resp.StatusCode -eq 200)
    } catch {
        return $false
    }
}

# Locate the dsh entry script: npm global prefix first, then common locations.
function Find-DshBinJs {
    try {
        $root = (& npm prefix -g 2>$null | Select-Object -First 1)
        if ($root) {
            $p = Join-Path $root 'node_modules\@deepseek-ai\dsh\lib\bin.js'
            if (Test-Path $p) { return $p }
        }
    } catch { }

    $cands = @(
        (Join-Path $env:APPDATA 'npm\node_modules\@deepseek-ai\dsh\lib\bin.js'),
        (Join-Path $env:LOCALAPPDATA 'npm\node_modules\@deepseek-ai\dsh\lib\bin.js'),
        'D:\npm-global\node_modules\@deepseek-ai\dsh\lib\bin.js'
    )
    $hit = $cands | Where-Object { Test-Path $_ } | Select-Object -First 1
    if ($hit) { return $hit }
    return $null
}

# 1) already running -> open browser and exit
if (Test-Server) {
    Start-Process $url
    exit 0
}

# 2) start dsh web hidden
$binJs = Find-DshBinJs
if ($binJs) {
    Start-Process -FilePath 'node.exe' -ArgumentList "`"$binJs`"", 'web' -WindowStyle Hidden
} else {
    Start-Process -FilePath 'cmd.exe' -ArgumentList '/c', 'npx @deepseek-ai/dsh web' -WindowStyle Hidden
}

# 3) wait until the server comes up
$deadline = (Get-Date).AddSeconds($timeoutSec)
while ((Get-Date) -lt $deadline) {
    if (Test-Server) { break }
    Start-Sleep -Milliseconds 1000
}

Start-Sleep -Milliseconds 500
Start-Process $url
exit 0
