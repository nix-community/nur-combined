#!/bin/sh

# include common definitions
# shellcheck source=scripts/core/sxmo_common.sh
. sxmo_common.sh

# Create xdg user directories, such as ~/Pictures
xdg-user-dirs-update

sxmo_daemons.sh start daemon_manager superd -v

# let time to superd to start correctly
while ! superctl status > /dev/null 2>&1; do
	sleep 0.5
done

# Periodically update some status bar components
sxmo_hook_statusbar.sh all
sxmo_daemons.sh start statusbar_periodics sxmo_run_aligned.sh 60 \
	sxmo_hook_statusbar.sh periodics

# mako/dunst are required for warnings.
# load some other little things here too.
superctl start mako
superctl start sxmo_wob
superctl start sxmo_menumode_toggler
superctl start bonsaid
swaymsg output '*' bg "$SXMO_BG_IMG" fill

# To setup initial lock state
sxmo_hook_unlock.sh

# Turn on auto-suspend
if [ -w "/sys/power/wakeup_count" ] && [ -f "/sys/power/wake_lock" ]; then
	superctl start sxmo_autosuspend
fi

# Turn on lisgd
superctl start sxmo_hook_lisgd

# Start the desktop widget (e.g. clock)
superctl start sxmo_conky

# Monitor the battery
superctl start sxmo_battery_monitor

# It watch network changes and update the status bar icon by example
superctl start sxmo_networkmonitor

# The daemon that display notifications popup messages
superctl start sxmo_notificationmonitor

# monitor for headphone for statusbar
superctl start sxmo_soundmonitor

# rotate UI based on physical display angle by default
sxmo_daemons.sh start autorotate sxmo_autorotate.sh
