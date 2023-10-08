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
#   - WiFi chip *should* have a way to wake on connection state change, i just need to enable it?
#     - `iw phy phy0 wowlan enable disconnect` => Invalid argument (-22)
#     - `iw phy0 wowlan enable net-detect ...` (from man example) => Operation not supported (-95)
#     - Realtek Quick Start guide claims "CONFIG_WAKEUP_TYPE = 0x7" enables deauth wake up (bit 2), unicast wake up (bit 1), magic packet (bit 0)
#     - driver Makefile:
#       - #bit0: ROAM_ON_EXPIRED, #bit1: ROAM_ON_RESUME, #bit2: ROAM_ACTIVE
#       - CONFIG_ROAMING_FLAG = 0x3


{ config, lib, pkgs, ... }:
let
  cfg = config.sane.wowlan;
  patternOpts = with lib; types.submodule {
    options = {
      ipv4.destPort = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = ''
          IP port from which the packet was *sent*.
          use this if you want to wake when an outbound connection shows activity
          (e.g. this machine made a long-running HTTP request, and the other side finally has data for us).
        '';
      };
      ipv4.srcPort = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = ''
          IP port on which the packet was *received*.
          use this if you want to wake on inbound connections
          (e.g. sshing *into* this machine).
        '';
      };
      arp.queryIp = mkOption {
        type = types.nullOr (types.listOf types.int);
        default = null;
        description = ''
          IP address being queried.
          e.g. `[ 192 168 0 100 ]`
        '';
      };
    };
  };
  # bytesToStr: [ u8|null ] -> String
  #             format an array of octets into a pattern recognizable by iwpriv.
  #             a null byte means "don't care" at its position.
  bytesToStr = bytes: lib.concatStringsSep ":" (
    builtins.map
      (b: if b == null then "-" else hexByte b)
      bytes
  );
  # format a byte as hex, with leading zero to force a width of two characters.
  # the wlan driver doesn't parse single-character hex bytes.
  hexByte = b: if b < 16 then
    "0" + (lib.toHexString b)
  else
    lib.toHexString b;

  etherTypes.ipv4 = [ 08 00 ];  # 0x0800 = IPv4
  etherTypes.arp = [ 08 06 ];  # 0x0806 = ARP
  formatEthernetFrame = ethertype: dataBytes: let
    bytes = [
      # ethernet frame: <https://en.wikipedia.org/wiki/Ethernet_frame#Structure>
      ## dest MAC address (this should be the device's MAC, but i think that's implied?)
      null null null null null null
      ## src MAC address
      null null null null null null
      ## ethertype: <https://en.wikipedia.org/wiki/EtherType#Values>
    ] ++ etherTypes."${ethertype}"
      ++ dataBytes;
  in bytesToStr bytes;

  formatArpPattern = pat:
    formatEthernetFrame "arp" ([
      # ARP frame: <https://en.wikipedia.org/wiki/Address_Resolution_Protocol#Packet_structure>
      ## hardware type
      null null
      ## protocol type. same coding as EtherType
      08 00  # 0x0800 = IPv4
      ## hardware address length (i.e. MAC)
      06
      ## protocol address length (i.e. IP address)
      04
      ## operation
      00 01  # 0x0001 = request
      ## sender hardware address
      null null null null null null
      ## sender protocol address
      null null null null
      ## target hardware address
      ## this is left as "Don't Care" because the packets we want to match
      ## are those mapping protocol addr -> hw addr.
      ## sometimes clients do include this field if they've seen the address before though
      null null null null null null
      ## target protocol address
    ] ++ pat.queryIp);

  # formatIpv4Pattern: patternOpts.ipv4 -> String
  # produces a string like this (example matches source port=0x0a1b):
  # "-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:0a:1b:-:-"
  formatIpv4Pattern = pat: let
    destPortBytes = if pat.destPort != null then {
      high = pat.destPort / 256;
      low = lib.mod pat.destPort 256;
    } else {
      high = null; low = null;
    };
    srcPortBytes = if pat.srcPort != null then {
      high = pat.srcPort / 256;
      low = lib.mod pat.srcPort 256;
    } else {
      high = null; low = null;
    };
  in
    formatEthernetFrame "ipv4" [
      # IP frame: <https://en.wikipedia.org/wiki/Internet_Protocol_version_4#Header>
      ## Version, Internet Header Length. 0x45 = 69 decimal
      null  # should be 69 (0x45), but fails to wake if i include this
      ## Differentiated Services Code Point (DSCP), Explicit Congestion Notification (ECN)
      null
      ## total length
      null null
      ## identification
      null null
      ## flags, fragment offset
      null null
      ## Time-to-live
      null
      ## protocol: <https://en.wikipedia.org/wiki/List_of_IP_protocol_numbers>
      6  # 6 = TCP
      ## header checksum
      null null
      ## source IP addr
      null null null null
      ## dest IP addr
      null null null null

      # TCP frame: <https://en.wikipedia.org/wiki/Transmission_Control_Protocol#TCP_segment_structure>
      srcPortBytes.high srcPortBytes.low
      destPortBytes.high destPortBytes.low
      ## rest is Don't Care
    ];
in
{
  options = with lib; {
    sane.wowlan.enable = mkOption {
      default = false;
      type = types.bool;
    };
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
      path = [ pkgs.iw pkgs.wirelesstools ];
      script = let
        extractPatterns = pat: lib.flatten [
          (lib.optional (pat.ipv4 != { destPort = null; srcPort = null; }) (formatIpv4Pattern pat.ipv4))
          (lib.optional (pat.arp != { queryIp = null; }) (formatArpPattern pat.arp))
        ];
        allPatterns = lib.flatten (builtins.map extractPatterns cfg.patterns);
        encodePattern = pat: ''
          iwpriv wlan0 wow_set_pattern pattern=${pat}
        '';
        encodedPatterns = lib.concatStringsSep
          "\n"
          (builtins.map encodePattern allPatterns);
      in ''
        set -x
        iw phy0 wowlan enable any
        iwpriv wlan0 wow_set_pattern clean
        ${encodedPatterns}
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
