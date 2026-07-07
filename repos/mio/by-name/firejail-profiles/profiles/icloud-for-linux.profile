# Firejail profile for icloud-for-linux
# Description: Unofficial WebKitGTK wrappers for iCloud web apps
# Persistent local customizations
include icloud-for-linux.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/icloud-for-linux
noblacklist ${HOME}/.local/share/icloud-for-linux

mkdir ${HOME}/.config/icloud-for-linux
mkdir ${HOME}/.local/share/icloud-for-linux
whitelist ${HOME}/.config/icloud-for-linux
whitelist ${HOME}/.local/share/icloud-for-linux

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# WebKitGTK/Tauri does not support AppArmor well
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

# WebKit needs namespaces for its renderer
ignore restrict-namespaces

private-dev

dbus-user filter
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.Notifications
dbus-system none
