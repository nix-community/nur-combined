@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish_chocolatey.ps1" %*
