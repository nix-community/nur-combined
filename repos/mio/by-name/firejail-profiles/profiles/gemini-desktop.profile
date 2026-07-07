# Firejail profile for gemini-desktop
# Description: Desktop client for Google Gemini
# Persistent local customizations
include gemini-desktop.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/gemini-desktop
noblacklist ${HOME}/.config/Gemini Desktop
noblacklist ${HOME}/.local/share/gemini-desktop

mkdir ${HOME}/.config/gemini-desktop
mkdir ${HOME}/.local/share/gemini-desktop
whitelist ${HOME}/.config/gemini-desktop
whitelist ${HOME}/.local/share/gemini-desktop

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
