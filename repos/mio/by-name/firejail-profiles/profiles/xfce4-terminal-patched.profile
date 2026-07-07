# Firejail profile for xfce4-terminal-patched
# Description: XFCE4 terminal emulator with Set Title patch
# Persistent local customizations
include xfce4-terminal-patched.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/xfce4/terminal

mkdir ${HOME}/.config/xfce4
mkdir ${HOME}/.config/xfce4/terminal
whitelist ${HOME}/.config/xfce4
whitelist ${HOME}/.config/xfce4/terminal

caps.drop all
# No network for terminal itself (spawned processes may use it)
net none
nogroups
noinput
noroot
nou2f
protocol unix
seccomp

# Terminal emulators need namespace access for PTYs
ignore restrict-namespaces

private-dev

dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-system none
