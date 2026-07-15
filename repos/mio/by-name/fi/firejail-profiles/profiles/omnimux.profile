# Firejail profile for omnimux
# Description: Multi-tab Flutter/GTK terminal UI for local and remote tmux
# This profile is part of the nurpkgs firejail-profiles package.
# Persistent local customizations
include omnimux.local
# Persistent global definitions
include globals.local

# omnimux is a Flutter/GTK app that manages tmux over local shell or SSH.
# It needs: network (SSH), ~/.ssh (keys/config), PTY namespaces,
# GTK/Flutter runtime, and (optionally) its config directory.

include disable-common.inc
include disable-programs.inc

# Allow omnimux config dir (if used later)
noblacklist ${HOME}/.config/omnimux
mkdir ${HOME}/.config/omnimux
whitelist ${HOME}/.config/omnimux

# Allow SSH keys and config
noblacklist ${HOME}/.ssh
whitelist ${HOME}/.ssh

# Allow known_hosts writes (ssh updates this on first connect)
whitelist ${HOME}/.ssh/known_hosts

# SSH agent sockets — firejail only expands known macros (${HOME}, ${RUNUSER},
# etc.); ${SSH_AUTH_SOCK} is NOT a profile macro (firejail#3884). Allow common
# concrete paths instead.
noblacklist ${RUNUSER}/ssh-agent.socket
whitelist ${RUNUSER}/ssh-agent.socket
noblacklist ${RUNUSER}/openssh_agent
whitelist ${RUNUSER}/openssh_agent
noblacklist /tmp/ssh-*
whitelist /tmp/ssh-*

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

caps.drop all
netfilter
nodvd
# Terminals need keyboard/pointer; do not set noinput
nonewprivs
noroot
nosound
notv
nou2f
novideo
# Unix for Flutter/GTK IPC; inet for SSH
protocol unix,inet,inet6
seccomp

# PTY creation requires namespace access
ignore restrict-namespaces

private-dev

dbus-user filter
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.Notifications
dbus-system none
