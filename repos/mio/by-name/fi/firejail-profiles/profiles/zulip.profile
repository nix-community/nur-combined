# Firejail profile for zulip (NixOS-friendly; Electron-based)
# Persistent local customizations
include zulip.local
# Persistent global definitions
include globals.local

# Must come before include electron-common.profile (sets dbus-user none / netfilter).
ignore noinput
ignore dbus-user none
ignore dbus-system none
ignore netfilter
ignore noexec /tmp
ignore apparmor

noblacklist ${HOME}/.config/Zulip

mkdir ${HOME}/.config/Zulip
whitelist ${HOME}/.config/Zulip

private-etc @tls-ca

# NixOS: private-bin cannot resolve xdg-open from the store; use system paths instead.
ignore noroot
whitelist /run/current-system
whitelist /run/wrappers
ignore private-bin

include electron-common.profile

dbus-user filter
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.portal.Documents
dbus-user.talk org.freedesktop.portal.OpenURI
dbus-user.talk org.freedesktop.portal.Settings
dbus-user.talk org.freedesktop.DBus
dbus-user.talk ca.desrt.dconf
dbus-user.talk org.freedesktop.Notifications
dbus-system none
