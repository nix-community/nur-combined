# Firejail profile for chatall
# Description: Chat with multiple AI bots simultaneously
# Persistent local customizations
include chatall.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/ChatALL
noblacklist ${HOME}/.local/share/ChatALL

mkdir ${HOME}/.config/ChatALL
mkdir ${HOME}/.local/share/ChatALL
whitelist ${HOME}/.config/ChatALL
whitelist ${HOME}/.local/share/ChatALL

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
