# Firejail profile for chatgpt-desktop-client
# Description: Desktop client for ChatGPT
# Persistent local customizations
include chatgpt-desktop-client.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/chatgpt-desktop-client
noblacklist ${HOME}/.local/share/chatgpt-desktop-client

mkdir ${HOME}/.config/chatgpt-desktop-client
mkdir ${HOME}/.local/share/chatgpt-desktop-client
whitelist ${HOME}/.config/chatgpt-desktop-client
whitelist ${HOME}/.local/share/chatgpt-desktop-client

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
