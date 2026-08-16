# ============================================================
#  setup.ps1 — DeepSeek Harness 一键部署
#
#  流程:
#    1) 检测 Node.js 环境（前提条件）
#    2) 没有则自动安装（winget 安装 Node.js LTS）
#    3) 全局安装 @deepseek-ai/dsh
#    4) 验证 dsh 可用
#    5) 在桌面创建 "DeepSeek Harness" 双击图标
#    6) (可选) 创建 "DeepSeek 官网" 蓝鲸鱼图标（自动区分国内/国际官网）
#  用法:
#    右键 "使用 PowerShell 运行"，或
#    powershell -NoProfile -ExecutionPolicy Bypass -File setup.ps1
# ============================================================
$ErrorActionPreference = 'Stop'

Write-Host ''
Write-Host '============================================' -ForegroundColor Cyan
Write-Host '        DeepSeek Harness 一键部署' -ForegroundColor Cyan
Write-Host '============================================' -ForegroundColor Cyan

# ---- [1/4] 检测 Node.js（部署前提）----
$node = Get-Command node -ErrorAction SilentlyContinue
if (-not $node) {
    Write-Host ''
    Write-Host '[1/4] 未检测到 Node.js，开始自动安装 LTS 版...' -ForegroundColor Yellow

    $winget = Get-Command winget -ErrorAction SilentlyContinue
    if ($winget) {
        winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements
        if ($LASTEXITCODE -ne 0) {
            Write-Host 'Node.js 安装失败，请手动安装 LTS 版后重试: https://nodejs.org/' -ForegroundColor Red
            exit 1
        }
        # 重新读取环境变量里的 PATH，让刚装的 node 立即可用
        $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
    } else {
        Write-Host '本机没有 winget，请手动安装 Node.js LTS 后重试: https://nodejs.org/' -ForegroundColor Red
        exit 1
    }

    $node = Get-Command node -ErrorAction SilentlyContinue
    if (-not $node) {
        Write-Host 'Node.js 已安装，但需要重开一个终端才能生效，请重开后再次运行本脚本。' -ForegroundColor Red
        exit 1
    }
}

$nodeVer = (& node --version)
Write-Host ''
Write-Host "[1/4] Node.js 环境就绪: $nodeVer" -ForegroundColor Green

# ---- [2/4] 安装 @deepseek-ai/dsh ----
Write-Host '[2/4] 正在全局安装 @deepseek-ai/dsh ...' -ForegroundColor Yellow
& npm install -g @deepseek-ai/dsh
if ($LASTEXITCODE -ne 0) {
    Write-Host 'npm 安装失败，请检查网络后重试。' -ForegroundColor Red
    exit 1
}

# ---- [3/4] 验证 dsh ----
$dshVer = (& dsh --version)
if ($LASTEXITCODE -ne 0 -or -not $dshVer) {
    Write-Host 'dsh 安装后无法运行，请检查 PATH 并重开终端后再试。' -ForegroundColor Red
    exit 1
}
Write-Host "[3/4] @deepseek-ai/dsh 已就绪: v$dshVer" -ForegroundColor Green

# ---- [4/4] 创建桌面快捷方式 ----
Write-Host '[4/4] 正在创建桌面快捷方式...' -ForegroundColor Yellow
& (Join-Path $PSScriptRoot 'make-shortcut.ps1')

# ---- (可选) DeepSeek 官网快捷方式（蓝鲸鱼图标，按地区跳转国内/国际官网）----
Write-Host ''
$answer = Read-Host '是否同时创建「DeepSeek 官网」快捷方式（蓝鲸鱼图标，双击直达官网，自动区分国内/国际版）？[y/N]'
if ($answer -match '^[Yy]') {
    Write-Host '正在创建 DeepSeek 官网快捷方式...' -ForegroundColor Yellow
    & (Join-Path $PSScriptRoot 'make-website-shortcut.ps1')
}

Write-Host ''
Write-Host '部署完成！双击桌面上的 "DeepSeek Harness" 图标即可打开。' -ForegroundColor Green
Write-Host '（首次启动需等待服务就绪，约 30~60 秒，之后秒开）' -ForegroundColor DarkGray
