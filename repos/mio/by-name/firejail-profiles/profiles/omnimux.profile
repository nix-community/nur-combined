# Firejail profile for omnimux
# Description: Multi-tab terminal GUI for tmux sessions across SSH hosts
# This profile is part of the nurpkgs firejail-profiles package.
# Persistent local customizations
include omnimux.local
# Persistent global definitions
include globals.local

# omnimux is a Tauri (WebKit/GTK) app that manages tmux over SSH.
# It needs: network (SSH), ~/.ssh (keys/config), PTY namespaces,
# WebKit renderer, and its own config directory.

include disable-common.inc
include disable-programs.inc

# Allow omnimux config dir
noblacklist ${HOME}/.config/omnimux
mkdir ${HOME}/.config/omnimux
whitelist ${HOME}/.config/omnimux

# Allow SSH keys and config (needed for SSH connections to remote hosts)
noblacklist ${HOME}/.ssh
whitelist ${HOME}/.ssh

# Allow known_hosts writes (ssh updates this on first connect)
whitelist ${HOME}/.ssh/known_hosts

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Tauri/WebKit needs apparmor disabled; report positive feedback before enabling
ignore apparmor

caps.drop all
# WebKit renderer requires IPC namespaces; do not isolate
#ipc-namespace
# Network needed for SSH connections
# net none  -- intentionally not set
netfilter
nodvd
noinput
nonewprivs
noroot
nosound
notv
nou2f
novideo
# Allow both unix sockets (WebKit IPC) and inet/inet6 (SSH)
protocol unix,inet,inet6
seccomp

# PTY creation requires namespace access; omnimux opens ptys for terminals
ignore restrict-namespaces

private-dev
# WebKit needs a real /tmp for shared memory and socket files
#private-tmp

# WebKit requires access to dbus-user for portal/theme/accessibility
# Loosen only if issues arise; start with filtered.
dbus-user filter
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.Notifications
dbus-system none
