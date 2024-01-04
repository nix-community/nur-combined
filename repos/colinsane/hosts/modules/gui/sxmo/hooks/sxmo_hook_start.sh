#!/usr/bin/env nix-shell
#!nix-shell -i bash -p systemd -p xdg-user-dirs
# this is based on upstream sxmo-utils sxmo_hook_start.sh
# but modified for nixos integration and specialize a bit to my needs
. sxmo_common.sh

# Create xdg user directories, such as ~/Pictures
xdg-user-dirs-update

sxmo_jobs.sh start daemon_manager

# Periodically update some status bar components
# don't: statusbar is managed by waybar
#   sxmo_hook_statusbar.sh all
#   sxmo_jobs.sh start statusbar_periodics sxmo_run_aligned.sh 60 \
#     sxmo_hook_statusbar.sh periodics

# TODO: start these externally, via `wantedBy` in nix
# don't: i don't use mako
#   superctl start mako
# systemctl --user start sxmo_wob
systemctl --user start sxmo_menumode_toggler
systemctl --user start bonsaid
# don't: sway background is managed externally
#   swaymsg output '*' bg "$SXMO_BG_IMG" fill

# To setup initial lock state
sxmo_state.sh set unlock

# Turn on auto-suspend
if [ -w "/sys/power/wakeup_count" ] && [ -f "/sys/power/wake_lock" ]; then
	systemctl --user start sxmo_autosuspend
fi

# Turn on lisgd
if [ ! -e "$XDG_CACHE_HOME"/sxmo/sxmo.nogesture ]; then
	systemctl --user start sxmo_hook_lisgd
fi

if [ "$(command -v ModemManager)" ]; then
	# Turn on the dbus-monitors for modem-related tasks
	systemctl --user start sxmo_modemmonitor

	# place a wakelock for 120s to allow the modem to fully warm up (eg25 +
	# elogind/systemd would do this for us, but we don't use those.)
	sxmo_wakelock.sh lock sxmo_modem_warming_up 120s
fi

# don't: conky is managed externally
#   superctl start sxmo_conky

# Monitor the battery
# don't: this is *exclusively* for sxmo_hook_statusbar.sh, which i don't use.
#   systemctl --user start sxmo_battery_monitor

# It watch network changes and update the status bar icon by example
# don't: this is for sxmo_hook_statusbar.sh, which i don't use.
# this means we never call sxmo_hook_network_{up,down,...}, but the defaults are no-op anyway
#   systemctl --user start sxmo_networkmonitor

# The daemon that display notifications popup messages
# more importantly: it lights the led green when a notification arrives
systemctl --user start sxmo_notificationmonitor

# monitor for headphone for statusbar
# this also invokes `wob` whenever the volume is changed
# don't: my volume monitoring is handled by sway
#   systemctl --user start sxmo_soundmonitor

# rotate UI based on physical display angle by default
if [ -n "$SXMO_AUTOROTATE" ]; then
	# TODO: this could use ~/.cache/sxmo/sxmo.autorotate like for lisgd above
	sxmo_jobs.sh start autorotate sxmo_autorotate.sh
fi

# Play a funky startup tune if you want (disabled by default)
#mpv --quiet --no-video ~/welcome.ogg &

# mmsd and vvmd
if [ -f "${SXMO_MMS_BASE_DIR:-"$HOME"/.mms/modemmanager}/mms" ]; then
	systemctl --user start mmsd-tng
fi

if [ -f "${SXMO_VVM_BASE_DIR:-"$HOME"/.vvm/modemmanager}/vvm" ]; then
	systemctl --user start vvmd
fi

# add some warnings if things are not setup correctly
if ! command -v "sxmo_deviceprofile_$SXMO_DEVICE_NAME.sh";  then
	sxmo_notify_user.sh --urgency=critical \
		"No deviceprofile found $SXMO_DEVICE_NAME. See: https://sxmo.org/deviceprofile"
fi

sxmo_migrate.sh state || sxmo_notify_user.sh --urgency=critical \
	"Config needs migration" "$? file(s) in your sxmo configuration are out of date and disabled - using defaults until you migrate (run sxmo_migrate.sh)"
