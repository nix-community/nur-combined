# Firejail profile for wiliwili (NixOS-friendly)
# This file is overwritten after every install/update
# Persistent local customizations
include wiliwili.local
# Persistent global definitions
include globals.local

quiet

noblacklist ${HOME}/.cache/wiliwili
noblacklist ${HOME}/.config/wiliwili
noblacklist ${HOME}/.local/state/wiliwili

include disable-common.inc
include disable-devel.inc
include disable-exec.inc
include disable-interpreters.inc
include disable-programs.inc
# include disable-shell.inc

read-only ${DESKTOP}
mkdir ${HOME}/.cache/wiliwili
mkdir ${HOME}/.config/wiliwili
mkdir ${HOME}/.local/state/wiliwili
whitelist ${HOME}/.cache/wiliwili
whitelist ${HOME}/.config/wiliwili
whitelist ${HOME}/.local/state/wiliwili
include whitelist-common.inc
include whitelist-player-common.inc
include whitelist-run-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Optional local media access
# whitelist ${HOME}/Videos
# whitelist ${HOME}/Downloads

apparmor
caps.drop all
netfilter
nogroups
nonewprivs
noroot
nou2f
protocol unix,inet,inet6,netlink
seccomp
seccomp.block-secondary

private-dev
private-tmp

# Allow basic desktop integration without full D-Bus access.
dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-user.talk org.freedesktop.portal.Desktop
dbus-system none

restrict-namespaces
