# Firejail profile for bilibili-linux
# Persistent local customizations
include bilibili.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.cache/bilibili
noblacklist ${HOME}/.config/bilibili
noblacklist ${HOME}/.local/share/bilibili

mkdir ${HOME}/.cache/bilibili
mkdir ${HOME}/.config/bilibili
mkdir ${HOME}/.local/share/bilibili
whitelist ${HOME}/.cache/bilibili
whitelist ${HOME}/.config/bilibili
whitelist ${HOME}/.local/share/bilibili

# Must come before include electron-common.profile (which sets netfilter, noinput, dbus-*).
ignore netfilter
ignore noinput
ignore dbus-user none
ignore dbus-system none

# Allow HTTPS/TLS
private-etc @tls-ca

# NixOS: private-bin cannot resolve paths from the store; use system paths instead.
ignore noroot
whitelist /run/current-system
whitelist /run/wrappers

# Redirect
include electron-common.profile

dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-user.talk org.freedesktop.portal.Desktop
# Allow NetworkManager on system dbus for network detection
dbus-system filter
dbus-system.talk org.freedesktop.NetworkManager
