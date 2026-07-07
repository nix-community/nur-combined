# Firejail profile for ccleste
# Description: Celeste Classic C source port (SDL2 game)
# Persistent local customizations
include ccleste.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.local/share/ccleste

mkdir ${HOME}/.local/share/ccleste
whitelist ${HOME}/.local/share/ccleste

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-usr-share-common.inc

caps.drop all
net none
protocol unix
nodvd
noinput
nonewprivs
noroot
notv
nou2f
seccomp
restrict-namespaces

private-dev
private-tmp

dbus-user none
dbus-system none
