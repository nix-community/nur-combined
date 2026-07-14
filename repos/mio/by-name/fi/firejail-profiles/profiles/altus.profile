# Firejail profile for altus
# Description: WhatsApp desktop client with themes and multi-account support
# Persistent local customizations
include altus.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/Altus

mkdir ${HOME}/.config/Altus
whitelist ${HOME}/.config/Altus

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
