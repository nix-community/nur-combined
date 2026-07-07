# Firejail profile for konfyt
# Description: Digital keyboard workstation for Linux (JACK/ALSA/FluidSynth)
# Persistent local customizations
include konfyt.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/konfyt
noblacklist ${HOME}/.local/share/konfyt
# Soundfonts may be stored in home
noblacklist ${HOME}/.local/share/sounds

mkdir ${HOME}/.config/konfyt
mkdir ${HOME}/.local/share/konfyt
whitelist ${HOME}/.config/konfyt
whitelist ${HOME}/.local/share/konfyt
whitelist ${HOME}/.local/share/sounds

include disable-common.inc
include disable-devel.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

caps.drop all
nodvd
noinput
nonewprivs
noroot
notv
nou2f
novideo
# No internet needed
net none
protocol unix
seccomp

private-dev
private-tmp

dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-system none
