# Firejail profile for meru
# Description: Gmail desktop application
# Persistent local customizations
include meru.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/meru
noblacklist ${HOME}/.local/share/meru

mkdir ${HOME}/.config/meru
mkdir ${HOME}/.local/share/meru
whitelist ${HOME}/.config/meru
whitelist ${HOME}/.local/share/meru

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
