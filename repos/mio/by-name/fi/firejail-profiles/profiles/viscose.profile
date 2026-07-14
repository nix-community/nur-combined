# Firejail profile for viscose
# Description: Viscose - freedom-respecting fork of Bambu Studio 3D slicer
# Persistent local customizations
include viscose.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/Viscose
noblacklist ${HOME}/.local/share/Viscose
noblacklist ${DOWNLOADS}

mkdir ${HOME}/.config/Viscose
mkdir ${HOME}/.local/share/Viscose
whitelist ${HOME}/.config/Viscose
whitelist ${HOME}/.local/share/Viscose
whitelist ${DOWNLOADS}

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

caps.drop all
netfilter
protocol unix,inet,inet6
nodvd
noinput
nonewprivs
noroot
nosound
notv
nou2f
novideo
seccomp
restrict-namespaces

private-dev

dbus-user filter
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.Notifications
dbus-system none
