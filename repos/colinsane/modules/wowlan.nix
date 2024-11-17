# wake on wireless LAN
# developed for the PinePhone (rtl8723cs), but may work on other systems.
# key info was found from this chat between Peetz0r and megi: <https://irclog.whitequark.org/linux-sunxi/2021-02-19>
# additionally in the Realtek "Quick Guide For Wake on WLAN": <https://gist.github.com/Peetz0r/bf8fd93a60962b4afcf2daeb4305da40#file-quick_start_guide_for_wow-pdf>
# megi's devlog which enabled WOWLAN: <https://xnux.eu/log/031.html>
# driver lives in Megi's kernel tree, at drivers/staging/rtl8723cs/Makefile
#
# wowlan configuration can be inspected with:
# - `iw phy0 wowlan`
# - `cat /proc/net/rtl8723cs/wlan0/wow_pattern_info`
# - the "pattern mask" is a bitfield, where each bit `i` indicates if the "pattern content" byte at index `i` must match, or should be treated as Don't Care (`-`)
#
# wakeup sources can be monitored with:
# - `cat /proc/interrupts | rg rtw_wifi_gpio_wakeup`
# - e.g. `cat /sys/kernel/irq/25/actions` (if the above points to irq 25)
#
# caveats:
# - can take 15s or more from when the packet is broadcast to when an application services it.
# - WiFi doesn't respond to arp queries, so the sender might not actually know how to route
#   the packet to WiFi device at all.
#   - run `arp -s <ip-addr> <mac-addr>` on the sender to hardcode an arp association.
#   - driver Makefile mentions ARP support though:
#     - #bit3: ARP enable, bit2: deauth, bit1: unicast, bit0: magic pkt.
#     - CONFIG_WAKEUP_TYPE = 0xf
#     - CONFIG_IP_R_MONITOR = n #arp VOQ and high rate
#     - #bit0: disBBRF off, #bit1: Wireless remote controller (WRC)
#     - CONFIG_SUSPEND_TYPE = 0  (i think this is correct)
#     - CONFIG_LPS_MODE = 1  (setting to 0 would disable LPS)
#   - maybe ARP gets disabled as part of the power saving features (iw phy ... power-save; CONFIG_POWER_SAVING=y)?
#   - driver code hints that some things like wake on arp are conditional on the state of AP association at the `wowlan enable` call.
#     so maybe it's proper to call `iw wowlan enable` immediately before *every* suspend instead of just once at boot
# - packet matching happens below the OS, so it's not generic over virtual network devices like tunnels.
#   Wake On Lan with a VPN effectively requires that you wake on *every* packet routed via that VPN
#   since the meaning within any packet isn't obvious to the chipset.
#
# known problems:
# - may fail to wake on LAN, with the following signature after power-button wake:
#   ```
#   wpa_supplicant: wlan0: CTRL-EVENT-DISCONNECTED bssid=xx:xx:xx:xx:xx:xx reason=6
#   wpa_supplicant: wlan0: Trying to associate with xx:xx:xx:xx:xx:xx (SSID='xx' freq=2437 MHz)
#   wpa_supplicant: wlan0: CTRL-EVENT-REGDOM-CHANGE init=CORE type=WORLD
#   wpa_supplicant: wlan0: CTRL-EVENT-STARTED-CHANNEL-SWITCH freq=2437 ht_enabled=1 ch_offset=0 ch_width=20 MHz cf1=2437 cf2=0
#   wpa_supplicant: wlan0: Associated with xx:xx:xx:xx:xx:xx
#   wpa_supplicant: wlan0: CTRL-EVENT-SUBNET-STATUS-UPDATE status=0
#   wpa_supplicant: wlan0: WPA: Key negotiation completed with xx:xx:xx:xx:xx:xx [PTK=CCMP GTK=CCMP]
#   wpa_supplicant: wlan0: CTRL-EVENT-CONNECTED - Connection to xx:xx:xx:xx:xx:xx completed [id=0 id_str=]
#   ```
#   - observed after a suspension of 67 minutes.
#   - but also observed after a suspension of just 5 minutes.
#   - WiFi chip *should* have a way to wake on connection state change, i just need to enable it?
#     - `iw phy phy0 wowlan enable disconnect` => Invalid argument (-22)
#     - `iw phy0 wowlan enable net-detect ...` (from man example) => Operation not supported (-95)
#     - Realtek Quick Start guide claims "CONFIG_WAKEUP_TYPE = 0x7" enables deauth wake up (bit 2), unicast wake up (bit 1), magic packet (bit 0)
#     - driver Makefile:
#       - #bit0: ROAM_ON_EXPIRED, #bit1: ROAM_ON_RESUME, #bit2: ROAM_ACTIVE
#       - CONFIG_ROAMING_FLAG = 0x3
# - may fail to wake on LAN, even without any signature like the above
#   - observed after a suspension of 10 minutes, trying to contact from laptop (laptop would have previously not contacted moby)
#   - in many cases the wake reason is still 0x23, even as it sleeps for the whole alloted 300s.
#     - then it's likely a race condition with the WiFi chip raising the wake signal *as* the CPU is falling asleep, and the CPU misses it.
#     - this is testable: phone would wake 100% if all networked services are disabled (so it's not receiving packets near the time it enters sleep)
#     - TODO: change the wake event from edge-triggered to level-triggered.
# - may disassociate from WiFi and *refuse to reassociate even via nmtui, restarting NetworkManager/wpa_supplicant/polkit*
#   - solution is `modprobe -r 8723cs && modprobe 8723cs`, then way a couple minutes.
#   - possible this only happens when the driver is compiled with CONFIG_GTK_OL (or CONFIG_ARP_KEEP_ALIVE).
#   - signature:
#     - `Oct 10 14:42:40 moby sxmo_autosuspend-start[1312366]: DEBUG:__main__:invoking: iwpriv wlan0 wow_set_pattern pattern=-:-:-:-:-:-:-:-:-:-:-:-:08:00:-:-:-:-:-:-:-:-:-:06:-:-:-:-:-:-:-:-:-:-:-:-:00:16`
#     - `Oct 10 14:42:40 moby kernel: [Warning] Error C2H ID=128, len=126`
#     - `Oct 10 14:42:55 moby NetworkManager[2750]: <warn>  [1696948975.4162] device (wlan0): link timed out.`
#     - `Oct 10 14:42:55 moby NetworkManager[2750]: <warn>  [1696948975.4749] device (wlan0): Activation: failed for connection 'xx'`
#     - `Oct 10 14:42:59 moby wpa_supplicant[2845]: wlan0: CTRL-EVENT-STARTED-CHANNEL-SWITCH freq=2437 ht_enabled=1 ch_offset=0 ch_width=20 MHz cf1=2437 cf2=0`
#     - `Oct 10 14:43:00 moby wpa_supplicant[2845]: wlan0: CTRL-EVENT-ASSOC-REJECT status_code=1`
#     - `Oct 10 14:43:00 moby wpa_supplicant[2845]: wlan0: CTRL-EVENT-SSID-TEMP-DISABLED id=0 ssid="xx" auth_failures=1 duration=10 reason=CONN_FAILED`
#     - `Oct 10 14:43:00 moby wpa_supplicant[2845]: wlan0: CTRL-EVENT-REGDOM-CHANGE init=CORE type=WORLD`
#     - (then wpa_supplicant tries again)
#     - `Oct 10 14:43:24 moby NetworkManager[2750]: <warn>  [1696949004.4165] device (wlan0): Activation: (wifi) association took too long`
#     - `Oct 10 14:43:24 moby NetworkManager[2750]: <warn>  [1696949004.4201] device (wlan0): Activation: (wifi) asking for new secrets`
#     - (above wpa_supplicant entries and these last two NM entries then repeat multiple times per minute, until driver reprobe)
#
# TODO: remove this file
# it's been obsoleted by hosts/modules/gui/sxmo/hooks/sxmo_suspend.sh


{ config, lib, pkgs, ... }:
let
  cfg = config.sane.wowlan;
  patternOpts = with lib; types.submodule {
    options = {
      tcp.destPort = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = ''
          IP port from which the packet was *sent*.
          use this if you want to wake when an outbound connection shows activity
          (e.g. this machine made a long-running HTTP request, and the other side finally has data for us).
        '';
      };
      tcp.sourcePort = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = ''
          IP port on which the packet was *received*.
          use this if you want to wake on inbound connections
          (e.g. sshing *into* this machine).
        '';
      };
      arp.destIp = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          IP address being queried.
          e.g. `"192.168.0.100"`
        '';
      };
    };
  };
in
{
  options = with lib; {
    sane.wowlan.enable = mkEnableOption "Wake on Wireless LAN packets";
    sane.wowlan.patterns = mkOption {
      default = [];
      type = types.listOf patternOpts;
      description = ''
        each entry represents a pattern which if seen in a packet should wake the system.
        if any pattern matches, the system will wake.
        for a pattern to match, all of its non-null fields must match.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.wowlan = {
      description = "configure the WiFi chip to wake the system on specific activity";
      path = [ pkgs.rtl8723cs-wowlan ];
      script = let
        tcpArgs = { destPort, sourcePort }:
          [ "tcp" ]
          ++ lib.optionals (destPort != null) [ "--dest-port" (builtins.toString destPort) ]
          ++ lib.optionals (sourcePort != null) [ "--source-port" (builtins.toString sourcePort) ]
        ;
        arpArgs = { destIp }:
          [ "arp" ]
          ++ lib.optionals (destIp != null) [ "--dest-ip" (builtins.toString destIp) ]
        ;
        maybeCallHelper = maybe: args:
          lib.optionalString
            maybe
            ((lib.escapeShellArgs ([ "rtl8723cs-wowlan" ] ++ args)) + "\n")
        ;
        applyPattern = pat:
          (maybeCallHelper (pat.tcp != { destPort = null; sourcePort = null; }) (tcpArgs pat.tcp))
          +
          (maybeCallHelper (pat.arp != { destIp = null; }) (arpArgs pat.arp))
        ;
        appliedPatterns = lib.concatStringsSep
          ""
          (builtins.map applyPattern cfg.patterns);
      in ''
        rtl8723cs-wowlan enable-clean
        ${appliedPatterns}
      '';
      serviceConfig = {
        # TODO: re-run this periodically, just to be sure?
        # it's kinda bad if this fails or gets undone unexpectedly.
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        RestartSec = "30s";
      };
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
    };
  };
}
