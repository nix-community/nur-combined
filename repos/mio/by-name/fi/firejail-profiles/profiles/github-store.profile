# Firejail profile for github-store
# Description: Cross-platform app store for GitHub releases (JVM/Compose Desktop)
# Persistent local customizations
include github-store.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/github-store
noblacklist ${HOME}/.local/share/github-store
noblacklist ${DOWNLOADS}

mkdir ${HOME}/.config/github-store
mkdir ${HOME}/.local/share/github-store
whitelist ${HOME}/.config/github-store
whitelist ${HOME}/.local/share/github-store
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
private-tmp

dbus-user filter
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.Notifications
dbus-system none
