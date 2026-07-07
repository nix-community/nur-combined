# Firejail profile for orca-slicer-for-bambu
# Description: OrcaSlicer with full BambuNetwork support for Bambu Lab printers
# Persistent local customizations
include orca-slicer-for-bambu.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/OrcaSlicer
noblacklist ${HOME}/.local/share/OrcaSlicer
noblacklist ${DOWNLOADS}

mkdir ${HOME}/.config/OrcaSlicer
mkdir ${HOME}/.local/share/OrcaSlicer
whitelist ${HOME}/.config/OrcaSlicer
whitelist ${HOME}/.local/share/OrcaSlicer
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
