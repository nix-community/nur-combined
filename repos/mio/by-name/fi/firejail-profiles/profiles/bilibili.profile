# Firejail profile for bilibili
# Description: Bilibili video platform desktop client
# Persistent local customizations
include bilibili.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/bilibili
noblacklist ${HOME}/.local/share/bilibili

mkdir ${HOME}/.config/bilibili
mkdir ${HOME}/.local/share/bilibili
whitelist ${HOME}/.config/bilibili
whitelist ${HOME}/.local/share/bilibili

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
