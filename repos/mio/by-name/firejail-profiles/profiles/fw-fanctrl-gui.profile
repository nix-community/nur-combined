# Firejail profile for fw-fanctrl-gui
# Description: Framework fan control GUI (Python/customtkinter)
# Persistent local customizations
include fw-fanctrl-gui.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/fw-fanctrl-gui

mkdir ${HOME}/.config/fw-fanctrl-gui
whitelist ${HOME}/.config/fw-fanctrl-gui

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

caps.drop all
net none
protocol unix
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
dbus-user.talk org.freedesktop.Notifications
dbus-system filter
dbus-system.talk org.freedesktop.fanctrl
