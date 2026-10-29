@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish_azure_artifacts.ps1" %*
