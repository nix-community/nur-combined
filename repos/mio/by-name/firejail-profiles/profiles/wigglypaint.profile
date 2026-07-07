# Firejail profile for wigglypaint
# Description: Jiggly drawing program built with Decker
# Persistent local customizations
include wigglypaint.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.local/share/wigglypaint
noblacklist ${DOCUMENTS}

mkdir ${HOME}/.local/share/wigglypaint
whitelist ${HOME}/.local/share/wigglypaint
whitelist ${DOCUMENTS}

include disable-common.inc
include disable-programs.inc

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

dbus-user none
dbus-system none
