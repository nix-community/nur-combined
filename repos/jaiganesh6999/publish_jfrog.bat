@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0publish_jfrog.ps1" %*
