# Firejail profile for ultimate-vocal-remover
# Description: AI vocal remover using deep neural networks (Python/Tkinter)
# Persistent local customizations
include ultimate-vocal-remover.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.local/share/ultimatevocalremovergui
noblacklist ${HOME}/.cache/ultimatevocalremovergui
noblacklist ${DOWNLOADS}
noblacklist ${MUSIC}

mkdir ${HOME}/.local/share/ultimatevocalremovergui
mkdir ${HOME}/.cache/ultimatevocalremovergui
whitelist ${HOME}/.local/share/ultimatevocalremovergui
whitelist ${HOME}/.cache/ultimatevocalremovergui
# Allow access to audio files for processing
whitelist ${DOWNLOADS}
whitelist ${MUSIC}

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

caps.drop all
# Network needed for model downloads
netfilter
protocol unix,inet,inet6
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

dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-system none
