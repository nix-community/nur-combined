@echo off
wsl --shell-type login -- /bin/sh -c "source /home/me/.bashrc; while true; sleep 9999999; echo hi; done &"
