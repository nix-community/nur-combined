@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish_cloudsmith.ps1" %*
