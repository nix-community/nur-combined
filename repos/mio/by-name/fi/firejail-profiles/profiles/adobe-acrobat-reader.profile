# Firejail profile for adobe-acrobat-reader (mkWindowsAppNoCC launcher)
# Based on AUR acroread-dc-wine by Smoolak and mmtrt (Snap package).
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
noblacklist ${HOME}/.config/adobe-acrobat-reader
noblacklist /tmp
