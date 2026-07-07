# Firejail profile for browseros
# Description: BrowserOS AI-driven web browser
# Persistent local customizations
include browseros.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/browseros
noblacklist ${HOME}/.local/share/browseros
noblacklist ${DOWNLOADS}

mkdir ${HOME}/.config/browseros
mkdir ${HOME}/.local/share/browseros
whitelist ${HOME}/.config/browseros
whitelist ${HOME}/.local/share/browseros
whitelist ${DOWNLOADS}

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
