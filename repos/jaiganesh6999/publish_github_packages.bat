@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish_github_packages.ps1" %*
