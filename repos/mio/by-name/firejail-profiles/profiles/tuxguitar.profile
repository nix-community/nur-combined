# Firejail profile for tuxguitar
# Description: Multitrack guitar tablature editor and player (Java/SWT)
# Persistent local customizations
include tuxguitar.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.tuxguitar
noblacklist ${HOME}/.local/share/tuxguitar

mkdir ${HOME}/.tuxguitar
mkdir ${HOME}/.local/share/tuxguitar
whitelist ${HOME}/.tuxguitar
whitelist ${HOME}/.local/share/tuxguitar
# Allow access to tablature files
noblacklist ${DOCUMENTS}
whitelist ${DOCUMENTS}

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
notv
nou2f
novideo
seccomp
restrict-namespaces

private-dev
private-tmp

dbus-user none
dbus-system none
