@echo off
rem One-click installer entry: runs setup.ps1 with execution policy bypass.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup.ps1"
echo.
pause
