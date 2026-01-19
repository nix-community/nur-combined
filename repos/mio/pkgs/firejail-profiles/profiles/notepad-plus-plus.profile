# Firejail profile for notepad++ (mkWindowsAppNoCC launcher)
# Based on the mkWindowsApp pattern used in this repo.
include wine.profile

# mkWindowsApp uses FUSE; wine.profile's private-dev hides /dev/fuse.
ignore private-dev

noblacklist ${HOME}/.cache/mkWindowsApp
noblacklist ${HOME}/.config/mkWindowsApp
noblacklist ${HOME}/.config/Notepad++
