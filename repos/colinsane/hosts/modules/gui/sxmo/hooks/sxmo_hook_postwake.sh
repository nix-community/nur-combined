#!/usr/bin/env nix-shell
#!nix-shell -i bash -p coreutils

# the default sxmo_postwake handler checks if the modem is offline
# and if so installs a wakelock to block suspend for 30s.
# that's a questionable place to install that logic, and i want to keep stuff
# out of the wake-from-sleep critical path, so i'm overriding this hook to disable that.

declare -A newmap
wowlan_reason[0x0]="not wowlan"

# mappings are found in megi's linux: drivers/staging/rtl8723cs/include/hal_com.h
wowlan_reason[0x1]="RX_PAIRWISEKEY"
wowlan_reason[0x2]="RX_GTK"
wowlan_reason[0x3]="RX_FOURWAY_HANDSHAKE"
wowlan_reason[0x4]="RX_DISASSOC"
wowlan_reason[0x8]="RX_DEAUTH"
wowlan_reason[0x9]="RX_ARP_REQUEST"
wowlan_reason[0x10]="FW_DECISION_DISCONNECT"
wowlan_reason[0x21]="RX_MAGIC_PKT"
wowlan_reason[0x22]="RX_UNICAST_PKT"
wowlan_reason[0x23]="RX_PATTERN_PKT"
wowlan_reason[0x24]="RTD3_SSID_MATCH"
wowlan_reason[0x30]="RX_REALWOW_V2_WAKEUP_PKT"
wowlan_reason[0x31]="RX_REALWOW_V2_ACK_LOST"
wowlan_reason[0x40]="ENABLE_FAIL_DMA_IDLE"
wowlan_reason[0x41]="ENABLE_FAIL_DMA_PAUSE"
wowlan_reason[0x42]="RTIME_FAIL_DMA_IDLE"
wowlan_reason[0x43]="RTIME_FAIL_DMA_PAUSE"
wowlan_reason[0x55]="RX_PNO"
#ifdef CONFIG_WOW_KEEP_ALIVE_PATTERN
wowlan_reason[0x60]="WOW_KEEPALIVE_ACK_TIMEOUT"
wowlan_reason[0x61]="WOW_KEEPALIVE_WAKE"
#endif/*CONFIG_WOW_KEEP_ALIVE_PATTERN*/
wowlan_reason[0x66]="AP_OFFLOAD_WAKEUP"
wowlan_reason[0xfd]="CLK_32K_UNLOCK"
wowlan_reason[0xfe]="CLK_32K_LOCK"

wowlan_text="$(cat /proc/net/rtl8723cs/wlan0/wowlan_last_wake_reason)"
wowlan_bits="${wowlan_text/last wake reason: /}"
wowlan_reason="${wowlan_reason[$wowlan_bits]}"
echo "exited suspend: $wowlan_text ($wowlan_reason)"
if [ "$wowlan_bits" != "0x0" ]; then
        # give time for userspace to respond to the wake event.
        # IM clients might have to re-establish TCP connections, perform sync, etc
        # until finally receiving the event which the system woke for,
        # TODO: if we suspended only very briefly, likely all the networking is in sync
        # and we don't have to wait this long.
        # there's no easy way *here* to know how long we slept for, though.
        sxmo_wakelock.sh lock postwake_work 25s
fi
