#!/usr/bin/env nix-shell
#!nix-shell -i bash -p sway

# this hook is mostly identical to default sxmo_hook_screenoff.sh except:
# - the LED frequency is adjusted from its default of "blink every 2s"
# - dwm-specific bits are removed

BLINK_FREQ=8

swaymsg mode default
sxmo_wm.sh dpms on
sxmo_wm.sh inputevent touchscreen off

sxmo_daemons.sh start periodic_blink sxmo_run_periodically.sh "$BLINK_FREQ" sxmo_led.sh blink red blue

wait

# avoid immediate suspension. particularly, ensure that we get at least one blink in
sxmo_wakelock.sh lock sxmo_hold_a_bit "$BLINK_FREQ"s
sxmo_wakelock.sh unlock sxmo_not_screenoff


