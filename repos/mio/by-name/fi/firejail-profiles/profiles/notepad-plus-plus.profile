# Firejail profile for notepad++ (mkWindowsAppNoCC launcher)
# Based on the mkWindowsApp pattern used in this repo.
include wine.profile

# mkWindowsApp uses FUSE (unionfs-fuse); wine.profile's private-dev hides /dev/fuse.
ignore private-dev

# unionfs-fuse needs namespace access to mount filesystems
ignore restrict-namespaces

# FUSE requires mount syscalls that are blocked by seccomp
ignore seccomp

# mkWindowsApp needs access to cache, config, and /tmp for WINEPREFIX
noblacklist ${HOME}/.cache/mkWindowsApp
noblacklist ${HOME}/.config/mkWindowsApp
noblacklist ${HOME}/.config/Notepad++
noblacklist /tmp
