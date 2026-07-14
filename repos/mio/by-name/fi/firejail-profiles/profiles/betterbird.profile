# Firejail profile for betterbird
# Description: Enhanced fork of Mozilla Thunderbird email client
# Persistent local customizations
include betterbird.local
# Persistent global definitions
# added by included profile
#include globals.local

noblacklist ${HOME}/.cache/betterbird
noblacklist ${HOME}/.betterbird
noblacklist ${HOME}/.thunderbird
noblacklist ${HOME}/.gnupg

mkdir ${HOME}/.cache/betterbird
mkdir ${HOME}/.betterbird
mkdir ${HOME}/.gnupg
whitelist ${HOME}/.cache/betterbird
whitelist ${HOME}/.betterbird
# Also allow thunderbird profile if coexisting
whitelist ${HOME}/.thunderbird
whitelist ${HOME}/.gnupg

ignore dbus-user none
dbus-user filter
dbus-user.own org.mozilla.betterbird.*
dbus-user.talk ca.desrt.dconf
dbus-user.talk org.freedesktop.Notifications
dbus-user.talk org.mozilla.*
writable-run-user

novideo

private-etc betterbird

ignore private-tmp

# Redirect
include firefox-common.profile
