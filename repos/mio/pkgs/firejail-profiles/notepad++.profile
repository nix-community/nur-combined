# Firejail profile for notepad++ (mkWindowsAppNoCC launcher)
# Based on the mkWindowsApp pattern used in this repo.
include wine.profile

noblacklist ${HOME}/.cache/mkWindowsApp
noblacklist ${HOME}/.config/mkWindowsApp
noblacklist ${HOME}/.config/Notepad++
