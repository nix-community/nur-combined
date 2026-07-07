# Firejail profile for downkyicore
# Description: Bilibili video downloader with Avalonia/.NET GUI
# Persistent local customizations
include downkyicore.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/DownKyi
noblacklist ${HOME}/.local/share/DownKyi
noblacklist ${DOWNLOADS}

mkdir ${HOME}/.config/DownKyi
mkdir ${HOME}/.local/share/DownKyi
whitelist ${HOME}/.config/DownKyi
whitelist ${HOME}/.local/share/DownKyi
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
ignore restrict-namespaces

private-dev
private-tmp

dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-system none
