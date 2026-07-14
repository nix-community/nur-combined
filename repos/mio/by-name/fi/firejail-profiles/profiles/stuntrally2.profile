# Firejail profile for stuntrally2
# Description: Stunt Rally racing game with online multiplayer (OGRE3D/SDL2)
# Persistent local customizations
include stuntrally2.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.stuntrally
noblacklist ${HOME}/.stuntrally3
noblacklist ${HOME}/.config/stuntrally

mkdir ${HOME}/.stuntrally
mkdir ${HOME}/.stuntrally3
mkdir ${HOME}/.config/stuntrally
whitelist ${HOME}/.stuntrally
whitelist ${HOME}/.stuntrally3
whitelist ${HOME}/.config/stuntrally

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-usr-share-common.inc

caps.drop all
# Multiplayer requires network
netfilter
protocol unix,inet,inet6
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
