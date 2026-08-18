# Firejail profile for gemini-desktop
# Persistent local customizations
include gemini-desktop.local
# Persistent global definitions
include globals.local

# Must come before include electron-common.profile (sets dbus-user none / netfilter).
ignore noinput
ignore dbus-user none
ignore dbus-system none
ignore netfilter

noblacklist ${HOME}/.cache/gemini-desktop
noblacklist ${HOME}/.config/gemini-desktop
noblacklist ${HOME}/.config/Gemini Desktop
noblacklist ${HOME}/.local/share/gemini-desktop

mkdir ${HOME}/.cache/gemini-desktop
mkdir ${HOME}/.config/gemini-desktop
mkdir ${HOME}/.config/Gemini Desktop
mkdir ${HOME}/.local/share/gemini-desktop
whitelist ${HOME}/.cache/gemini-desktop
whitelist ${HOME}/.config/gemini-desktop
whitelist ${HOME}/.config/Gemini Desktop
whitelist ${HOME}/.local/share/gemini-desktop

private-etc @tls-ca

# NixOS: private-bin cannot resolve xdg-open from the store; use system paths instead.
ignore noroot
whitelist /run/current-system
whitelist /run/wrappers
ignore private-bin

include electron-common.profile

dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.portal.OpenURI
dbus-system none
