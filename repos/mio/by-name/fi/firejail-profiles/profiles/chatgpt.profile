# Firejail profile for ChatGPT (Pake / Electron desktop wrapper)
# Persistent local customizations
include chatgpt.local
# Persistent global definitions
include globals.local

# Must come before include electron-common.profile (sets dbus-user none / netfilter).
ignore noinput
ignore dbus-user none
ignore dbus-system none
ignore netfilter

noblacklist ${HOME}/.config/ChatGPT
noblacklist ${HOME}/.config/chatgpt
noblacklist ${HOME}/.cache/ChatGPT
noblacklist ${HOME}/.cache/chatgpt
noblacklist ${HOME}/.local/share/ChatGPT
noblacklist ${HOME}/.local/share/chatgpt

mkdir ${HOME}/.config/ChatGPT
mkdir ${HOME}/.config/chatgpt
mkdir ${HOME}/.cache/ChatGPT
mkdir ${HOME}/.cache/chatgpt
mkdir ${HOME}/.local/share/ChatGPT
mkdir ${HOME}/.local/share/chatgpt
whitelist ${HOME}/.config/ChatGPT
whitelist ${HOME}/.config/chatgpt
whitelist ${HOME}/.cache/ChatGPT
whitelist ${HOME}/.cache/chatgpt
whitelist ${HOME}/.local/share/ChatGPT
whitelist ${HOME}/.local/share/chatgpt

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
dbus-user.talk org.freedesktop.portal.Documents
dbus-user.talk org.freedesktop.portal.OpenURI
dbus-system none
