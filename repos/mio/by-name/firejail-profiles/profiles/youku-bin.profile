# Firejail profile for youku-bin
# Description: Youku video platform desktop client
# Persistent local customizations
include youku-bin.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/youku
noblacklist ${HOME}/.local/share/youku

mkdir ${HOME}/.config/youku
mkdir ${HOME}/.local/share/youku
whitelist ${HOME}/.config/youku
whitelist ${HOME}/.local/share/youku

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
