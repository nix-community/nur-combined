# Firejail profile for bambu-studio-open
# Description: Bambu Studio 3D slicer with open-source networking plugin
# Persistent local customizations
include bambu-studio-open.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/BambuStudio
noblacklist ${HOME}/.local/share/BambuStudio
noblacklist ${DOWNLOADS}

mkdir ${HOME}/.config/BambuStudio
mkdir ${HOME}/.local/share/BambuStudio
whitelist ${HOME}/.config/BambuStudio
whitelist ${HOME}/.local/share/BambuStudio
whitelist ${DOWNLOADS}

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

caps.drop all
# Network for printer connectivity and model downloads
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
