# Firejail profile for waveterm
# Description: Modern terminal with widgets and AI integration (Electron + Go backend)
# Persistent local customizations
include waveterm.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.waveterm
noblacklist ${HOME}/.local/share/waveterm
noblacklist ${HOME}/.ssh

mkdir ${HOME}/.waveterm
mkdir ${HOME}/.local/share/waveterm
whitelist ${HOME}/.waveterm
whitelist ${HOME}/.local/share/waveterm
# SSH access needed for remote connections
whitelist ${HOME}/.ssh

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

# Terminal emulator needs PTY/namespace access
ignore restrict-namespaces

# Redirect
include electron-common.profile
