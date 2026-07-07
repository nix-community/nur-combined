# Firejail profile for prospect-mail
# Description: Unofficial desktop client for Microsoft Outlook
# Persistent local customizations
include prospect-mail.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/Prospect Mail
noblacklist ${HOME}/.local/share/Prospect Mail

mkdir ${HOME}/.config/Prospect Mail
mkdir ${HOME}/.local/share/Prospect Mail
whitelist ${HOME}/.config/Prospect Mail
whitelist ${HOME}/.local/share/Prospect Mail

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Redirect
include electron-common.profile
