# Firejail profile for icloud-mail
# Description: Unofficial desktop client for iCloud Mail
# Persistent local customizations
include icloud-mail.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/icloud-mail
noblacklist ${HOME}/.local/share/icloud-mail

mkdir ${HOME}/.config/icloud-mail
mkdir ${HOME}/.local/share/icloud-mail
whitelist ${HOME}/.config/icloud-mail
whitelist ${HOME}/.local/share/icloud-mail

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
