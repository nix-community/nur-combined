# Firejail profile for rclone-browser
# Description: Graphical frontend for rclone cloud storage manager
# Persistent local customizations
include rclone-browser.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/RcloneBrowser
noblacklist ${HOME}/.config/rclone
noblacklist ${DOWNLOADS}

mkdir ${HOME}/.config/RcloneBrowser
whitelist ${HOME}/.config/RcloneBrowser
# rclone config with credentials
noblacklist ${HOME}/.config/rclone
whitelist ${HOME}/.config/rclone
whitelist ${DOWNLOADS}

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

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
restrict-namespaces

private-dev
private-tmp

dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-system none
