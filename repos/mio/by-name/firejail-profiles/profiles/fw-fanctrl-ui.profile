# Firejail profile for fw-fanctrl-ui
# Description: System tray icon for fw-fanctrl Framework fan control (GTK)
# Persistent local customizations
include fw-fanctrl-ui.local
# Persistent global definitions
include globals.local

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

caps.drop all
# No internet needed; communicates with local daemon via D-Bus/socket
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
# fw-fanctrl daemon communicates over D-Bus
dbus-system.talk org.freedesktop.fanctrl
