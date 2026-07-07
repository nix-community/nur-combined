# Firejail profile for ryubing
# Description: Nintendo Switch emulator - community Ryujinx fork (Avalonia/.NET)
# Persistent local customizations
include ryubing.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/Ryujinx
noblacklist ${HOME}/.local/share/Ryujinx

mkdir ${HOME}/.config/Ryujinx
mkdir ${HOME}/.local/share/Ryujinx
whitelist ${HOME}/.config/Ryujinx
whitelist ${HOME}/.local/share/Ryujinx
# Game ROMs may be anywhere; user should add to ryubing.local
#whitelist ${HOME}/Games

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

caps.drop all
# No internet needed for local emulation (disable for online play)
net none
protocol unix
nodvd
noinput
nonewprivs
noroot
notv
nou2f
seccomp
# Avalonia may need namespaces
ignore restrict-namespaces

private-dev

dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-system none
