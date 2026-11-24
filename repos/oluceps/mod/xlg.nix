# Stardew Valley co-op relay ("xlg").
#
# The game host sits behind NAT and punches it by sending "bre@d" from its
# game port to <this node>:<port>; the punch is dropped here, but its public
# endpoint is remembered per destination port. Packets from the US peer are
# DNATed to that endpoint and masqueraded to <this node>:<port>, so the
# host's NAT sees replies to its own punch. Anything else is left alone.
{
  flake.modules.nixos.xlg =
    { config, lib, ... }:
    let
      inherit (lib) mkOption types;
      cfg = config.xlg;
      port = toString cfg.port;
      wan = cfg.wanInterface;
      # Mark picks the source NAT applied in postrouting.
      markSec = "0x24542";
    in
    {
      options.xlg = {
        usIPv4 = mkOption {
          type = types.str;
          description = "Public IPv4 address of the US peer.";
        };
        port = mkOption {
          type = types.port;
          default = 24642;
          description = "Game port, relayed on this node.";
        };
        wanInterface = mkOption {
          type = types.str;
          default = "eth0";
          description = "Interface the relayed packets leave through.";
        };
      };

      config = {
        networking.firewall.allowedUDPPorts = [ cfg.port ];

        networking.nftables.tables.xlg = {
          family = "inet";
          content = ''
            map sec {
              type inet_service : ipv4_addr . inet_service
            }

            # Remember the game host's public endpoint from its punch.
            chain request {
              delete @sec { udp dport : 0 . 0 } add @sec { udp dport : ip saddr . udp sport } counter drop
            }

            chain pre_filter {
              type filter hook prerouting priority raw;
              # 5 payload bytes after the UDP header == "bre@d"
              udp dport ${port} @th,64,40 0x6272654064 jump request
            }

            chain dstnat {
              type nat hook prerouting priority dstnat; policy accept;
              udp dport ${port} jump xlgdnat
            }

            chain xlgdnat {
              # US -> game host
              ip saddr ${cfg.usIPv4} mark set ${markSec} counter dnat ip to udp dport map @sec
              ip saddr ${cfg.usIPv4} counter drop
            }

            chain srcnat {
              type nat hook postrouting priority srcnat - 1;
              meta l4proto udp oifname "${wan}" mark ${markSec} masquerade to :${port}
            }
          '';
        };
      };
    };
}
