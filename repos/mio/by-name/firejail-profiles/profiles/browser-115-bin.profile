# Firejail profile for browser-115-bin
# Description: 115 Browser - cloud storage desktop client
# Persistent local customizations
include browser-115-bin.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/115Browser
noblacklist ${HOME}/.local/share/115Browser
noblacklist ${DOWNLOADS}

mkdir ${HOME}/.config/115Browser
mkdir ${HOME}/.local/share/115Browser
whitelist ${HOME}/.config/115Browser
whitelist ${HOME}/.local/share/115Browser
whitelist ${DOWNLOADS}

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
