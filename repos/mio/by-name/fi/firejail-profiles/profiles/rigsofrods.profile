# Firejail profile for Rigs of Rods zip release
noblacklist ~/Games/rigsofrods
noblacklist ~/.rigsofrods

#include ~/.config/firejail/openal.inc
include disable-common.inc
include disable-devel.inc
include disable-interpreters.inc
include disable-programs.inc
include disable-write-mnt.inc
include disable-proc.inc

mkdir ~/Games/rigsofrods
whitelist ~/Games/rigsofrods
mkdir ~/.rigsofrods
whitelist ~/.rigsofrods

caps.drop all
dbus-system none
dbus-user none
nodvd
netfilter
nogroups
nonewprivs
noprinters
noroot
notv
nou2f
novideo
protocol unix,inet,inet6
restrict-namespaces
#seccomp        # commented out to avoid hyper-threading mitigations causing potential performance hit
#seccomp.block-secondary
tracelog

disable-mnt
private-bin sh
private-dev
private-tmp

#noexec ${HOME} # uncomment if you have the binary at some other place
noexec /tmp
