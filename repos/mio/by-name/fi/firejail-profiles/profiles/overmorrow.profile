# Firejail profile for overmorrow
# Description: Flutter weather application
# Persistent local customizations
include overmorrow.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.local/share/overmorrow

mkdir ${HOME}/.local/share/overmorrow
whitelist ${HOME}/.local/share/overmorrow

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

caps.drop all
# Network needed for weather data
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
private-tmp

dbus-user filter
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.Notifications
dbus-system none
