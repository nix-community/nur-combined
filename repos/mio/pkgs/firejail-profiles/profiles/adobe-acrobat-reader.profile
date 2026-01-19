# Firejail profile for adobe-acrobat-reader (mkWindowsAppNoCC launcher)
# Based on AUR acroread-dc-wine by Smoolak and mmtrt (Snap package).
include wine.profile

noblacklist ${HOME}/.cache/mkWindowsApp
noblacklist ${HOME}/.config/mkWindowsApp
noblacklist ${HOME}/.config/adobe-acrobat-reader
