# Firejail profile for artcraft
# Description: Interactive AI image and video creation IDE (Tauri/WebKitGTK)
# Persistent local customizations
include artcraft.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/artcraft
noblacklist ${HOME}/.local/share/artcraft

mkdir ${HOME}/.config/artcraft
mkdir ${HOME}/.local/share/artcraft
whitelist ${HOME}/.config/artcraft
whitelist ${HOME}/.local/share/artcraft

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Tauri/WebKit does not support AppArmor well
ignore apparmor

caps.drop all
netfilter
nodvd
noinput
nonewprivs
noroot
nosound
notv
nou2f
novideo
protocol unix,inet,inet6
seccomp

# Tauri PTY requirements
ignore restrict-namespaces

private-dev

dbus-user filter
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.Notifications
dbus-system none
