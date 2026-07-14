# Firejail profile for losslesscut
# Description: Lossless video and audio editing tool
# Persistent local customizations
include losslesscut.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/LosslessCut
noblacklist ${HOME}/.local/share/LosslessCut
# Allow access to media files
noblacklist ${DOWNLOADS}
noblacklist ${VIDEOS}
noblacklist ${MUSIC}

mkdir ${HOME}/.config/LosslessCut
mkdir ${HOME}/.local/share/LosslessCut
whitelist ${HOME}/.config/LosslessCut
whitelist ${HOME}/.local/share/LosslessCut
whitelist ${DOWNLOADS}
whitelist ${VIDEOS}
whitelist ${MUSIC}

include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# No internet needed for local editing
ignore netfilter
net none

# Redirect
include electron-common.profile
