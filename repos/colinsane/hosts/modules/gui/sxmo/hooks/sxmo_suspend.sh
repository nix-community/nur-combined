#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils -p util-linux

# yeah, this isn't technically a hook, but the hook infrastructure isn't actually
# restricted to stuff that starts with sxmo_hook_ ...
#
# this script is only called by sxmo_autosuspend, which is small, so if i wanted to
# be more proper i could instead re-implement autosuspend + integrations.

. sxmo_common.sh

suspend_time=300

sxmo_log "calling suspend for duration: $suspend_time"

rtcwake -m mem -s "$suspend_time" || exit 1

sxmo_log "exited suspend: $(cat /proc/net/rtl8723cs/wlan0/wowlan_last_wake_reason)"

sxmo_hook_postwake.sh

