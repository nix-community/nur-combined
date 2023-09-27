# wake on wireless LAN
# developed for the PinePhone (rtl8723cs), but may work on other systems.
# key info was found from this chat between Peetz0r and megi: <https://irclog.whitequark.org/linux-sunxi/2021-02-19>
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
#   run `arp -s <ip-addr> <mac-addr>` on the sender to hardcode an arp association.
# - packet matching happens below the OS, so it's not generic over virtual network devices like tunnels.
#   Wake On Lan with a VPN effectively requires that you wake on *every* packet routed via that VPN
#   since the meaning within any packet isn't obvious to the chipset.

{ config, lib, pkgs, ... }:
let
  cfg = config.sane.wowlan;
  patternOpts = with lib; types.submodule {
    options = {
      destPort = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = ''
          IP port from which the packet was *sent*.
          use this if you want to wake when an outbound connection shows activity
          (e.g. this machine made a long-running HTTP request, and the other side finally has data for us).
        '';
      };
      srcPort = mkOption {
        type = types.nullOr types.port;
        default = null;
        description = ''
          IP port on which the packet was *received*.
          use this if you want to wake on inbound connections
          (e.g. sshing *into* this machine).
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
  # formatPattern: patternOpts -> String
  # produces a string like this (example matches source port=0x0a1b):
  # "-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:-:0a:1b:-:-"
  #
  # N.B.: the produced patterns match ONLY IPv4 -- not IPv6!
  formatPattern = pat: let
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

    bytes = [
      # ethernet frame: <https://en.wikipedia.org/wiki/Ethernet_frame#Structure>
      ## dest MAC address (this should be the device's MAC, but i think that's implied?)
      null null null null null null
      ## src MAC address
      null null null null null null
      ## ethertype: <https://en.wikipedia.org/wiki/EtherType#Values>
      08 00  # 0x0800 = IPv4

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
  in bytesToStr bytes;
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
        writePattern = pat: ''
          iwpriv wlan0 wow_set_pattern pattern=${formatPattern pat}
        '';
        writePatterns = lib.concatStringsSep
          "\n"
          (builtins.map writePattern cfg.patterns);
      in ''
        set -x
        iw phy0 wowlan enable any
        iwpriv wlan0 wow_set_pattern clean
        ${writePatterns}
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
