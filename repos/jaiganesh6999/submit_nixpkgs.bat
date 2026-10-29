@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0submit_nixpkgs.ps1" %*
