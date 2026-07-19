# Firejail profile for Komi-Store
# Description: Cross-platform app store for GitHub releases (JVM/Compose Desktop)
# Persistent local customizations
include Komi-Store.local
# Persistent global definitions
include globals.local

# Window state (WindowStateStore → XDG_CONFIG_HOME/Komi-Store)
noblacklist ${HOME}/.config/Komi-Store
# Room DB + DataStore (DesktopAppDataPaths → XDG_DATA_HOME/Komi-Store)
noblacklist ${HOME}/.local/share/Komi-Store
# Crash / session logs (CrashReporter → XDG_STATE_HOME/Komi-Store)
noblacklist ${HOME}/.local/state/Komi-Store
# Download cache (DesktopFileLocationsProvider → XDG_CACHE_HOME/githubstore)
noblacklist ${HOME}/.cache/githubstore
# Deep-link .desktop (DesktopDeepLink → github-store-deeplink.desktop)
noblacklist ${HOME}/.local/share/applications
# AppImage install / launch targets (DesktopInstaller / DesktopAppLauncher)
noblacklist ${HOME}/Applications
noblacklist ${HOME}/.local/bin
# User downloads (~/Downloads/Komi Store Downloads)
noblacklist ${DOWNLOADS}

mkdir ${HOME}/.config/Komi-Store
mkdir ${HOME}/.local/share/Komi-Store
mkdir ${HOME}/.local/state/Komi-Store
mkdir ${HOME}/.cache/githubstore
mkdir ${HOME}/.local/share/applications
mkdir ${HOME}/Applications
mkdir ${HOME}/.local/bin
whitelist ${HOME}/.config/Komi-Store
whitelist ${HOME}/.local/share/Komi-Store
whitelist ${HOME}/.local/state/Komi-Store
whitelist ${HOME}/.cache/githubstore
whitelist ${HOME}/.local/share/applications
whitelist ${HOME}/Applications
whitelist ${HOME}/.local/bin
whitelist ${DOWNLOADS}

include disable-common.inc
include disable-programs.inc

include whitelist-common.inc
include whitelist-runuser-common.inc
include whitelist-usr-share-common.inc
include whitelist-var-common.inc

caps.drop all
netfilter
protocol unix,inet,inet6
nodvd
noinput
nonewprivs
noroot
nosound
notv
nou2f
novideo
seccomp
restrict-namespaces

private-dev
private-tmp

dbus-user filter
dbus-user.talk org.freedesktop.portal.Desktop
dbus-user.talk org.freedesktop.Notifications
dbus-system none
