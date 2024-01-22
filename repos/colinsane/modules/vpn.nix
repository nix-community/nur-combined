# debugging:
# - `journalctl -u systemd-networkd`
#
# docs:
# - wireguard (nixos): <https://nixos.wiki/wiki/WireGuard#Setting_up_WireGuard_with_systemd-networkd>
# - wireguard (arch): <https://wiki.archlinux.org/title/WireGuard>

{ config, lib, pkgs, sane-lib, ... }:
let
  cfg = config.sane.vpn;
  vpnOpts = with lib; types.submodule ({ name, config, ... }: {
    options = {
      name = mkOption {
        type = types.str;
        description = ''
          read-only value: must match the attrName of this vpn.
        '';
      };
      id = mkOption {
        type = types.ints.between 1 99;
        description = ''
          unique integer identifier for this VPN.
          lower number = higher priority, in many senses.
          lowest number = default VPN to use when no other is specified, or when multiple are enabled in the same circumstance.
        '';
      };
      default = mkOption {
        type = types.bool;
        description = ''
          read-only value: set based on whichever VPN has the lowest id.
        '';
      };
      endpoint = mkOption {
        type = types.str;
        description = ''
          host:port which hosts the other end of the VPN.
          e.g. "vpn.example.com:55280"
        '';
      };
      publicKey = mkOption {
        type = types.str;
        description = ''
          pubkey of the remote peer.
        '';
      };
      addrV4 = mkOption {
        type = types.str;
        description = ''
          IP address of my end of the VPN.
          e.g. "172.27.12.34"
        '';
      };
      dns = mkOption {
        type = types.listOf types.str;
        default = [
          "46.227.67.134"
          "192.165.9.158"
        ];
        description = ''
          dns servers to use for traffic associated with this VPN.
        '';
      };
      bridgeDevice = mkOption {
        type = types.str;
        default = "br-${name}";
        description = ''
          name of the bridge net device which will be created and configured so as to route all its outbound traffic over the VPN.
        '';
      };
      privateKeyFile = mkOption {
        type = types.either types.str types.path;
        description = ''
          path to the private key for my end of the VPN.
          e.g. "/run/secrets/wg-home.priv"
        '';
      };
    };

    config = {
      inherit name;
      default = builtins.all (other: config.id <= other.id) (builtins.attrValues cfg);
    };
  });
  mkVpnConfig = name: { id, dns, endpoint, publicKey, addrV4, privateKeyFile, bridgeDevice, ... }: let
    fwmark = id + 10000;
    bridgeAddrV4 = "10.20.${builtins.toString id}.1/24";
  in {
    assertions = [
      {
        assertion = (lib.count (c: c.id == id) (builtins.attrValues cfg)) == 1;
        message = "multiple VPNs share id ${id}";
      }
    ];
    systemd.network.netdevs."98-${name}" = {
      # see: `man 5 systemd.netdev`
      netdevConfig = {
        Kind = "wireguard";
        Name = name;
      };
      wireguardConfig = {
        PrivateKeyFile = privateKeyFile;
        FirewallMark = id;
      };
      wireguardPeers = [{
        wireguardPeerConfig = {
          AllowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          Endpoint = endpoint;
          PublicKey = publicKey;
        };
      }];
    };
    systemd.network.networks."50-${name}" = {
      # see: `man 5 systemd.network`
      matchConfig.Name = name;
      networkConfig.Address = [ addrV4 ];
      networkConfig.DNS = dns;
      # TODO: `sane-vpn up <vpn>` should configure DNS to be sent over the VPN
      # DNSDefaultRoute: system DNS queries are sent to this link's DNS server
      # networkConfig.DNSDefaultRoute = true;
      # Domains = ~.: system DNS queries are sent to this link's DNS server
      # networkConfig.Domains = "~.";
      routingPolicyRules = [
        {
          routingPolicyRuleConfig = {
            # send traffic from the the container bridge out over the VPN.
            # the bridge itself does source nat (SNAT) to rewrite the packet source address to that of the VPNs
            # -- but that happens in POSTROUTING: *after* the kernel decides which interface to give the packet to next.
            # therefore, we have to route here based on the packet's address as it is in PREROUTING, i.e. the bridge address. weird!
            Priority = id;
            From = bridgeAddrV4;
            Table = id;
          };
        }
      ];
      routes = [{
        routeConfig.Table = id;
        routeConfig.Scope = "link";
        routeConfig.Destination = "0.0.0.0/0";
        routeConfig.Source = addrV4;
      }];
      # RequiredForOnline => should `systemd-networkd-wait-online` fail if this network can't come up?
      linkConfig.RequiredForOnline = false;
    };

    systemd.network.netdevs."99-${bridgeDevice}" = {
      netdevConfig.Kind = "bridge";
      netdevConfig.Name = bridgeDevice;
    };
    systemd.network.networks."51-${bridgeDevice}" = {
      matchConfig.Name = bridgeDevice;
      networkConfig.Description = "NATs inbound traffic to ${name}, intended for container isolation";
      networkConfig.Address = [ bridgeAddrV4 ];
      networkConfig.DNS = dns;
      # ConfigureWithoutCarrier: a bridge with no attached interface has no carrier (this is to be expected).
      #   systemd ordinarily waits for a carrier to be present before "configuring" the bridge.
      #   i tell it to not do that, so that i can assign an IP address to the bridge before i connect it to anything.
      #   alternative may be to issue the bridge a static MACAddress?
      #   see: <https://github.com/systemd/systemd/issues/9252#issuecomment-808710185>
      networkConfig.ConfigureWithoutCarrier = true;
      # networkConfig.DHCPServer = true;
      linkConfig.RequiredForOnline = false;
    };
    networking.localCommands = with pkgs; ''
      # view rules with:
      # - `sudo iptables -t nat --list-rules -v`
      # rewrite the source address of every packet leaving the container so that it's routable by the wg tunnel.
      # note that this alone doesn't get it routed *to* the wg device. we can't, since SNAT is POSTROUTING (not PREROUTING).
      #   that part's done by an `ip rule` entry.
      ${iptables}/bin/iptables -A POSTROUTING -t nat -s ${bridgeAddrV4} -j SNAT --to-source ${addrV4}
    '';

    # linux will drop inbound packets if it thinks a reply to that packet wouldn't exit via the same interface (rpfilter).
    # wg-quick has a solution via `iptables -j CONNMARK`, and that does work for system-wide VPNs,
    # but i couldn't get that to work for firejail/netns with SNAT, so set rpfilter to "loose".
    networking.firewall.checkReversePath = "loose";

    # networking.firewall.extraCommands = with pkgs; ''
    #   # wireguard packet marking. without this, rpfilter drops responses from a wireguard VPN
    #   # because the "reverse path check" fails (i.e. it thinks a response to the packet would go out via a different interface than what the wireguard packet arrived at).
    #   # debug with e.g. `iptables --list -v -n -t mangle`
    #   # - and `networking.firewall.logReversePathDrops = true;`, `networking.firewall.logRefusedPackets = true;`
    #   # - and `journalctl -k` to see dropped packets
    #   #
    #   # note that wg-quick also adds a rule to reject non-local traffic from all interfaces EXCEPT the tunnel.
    #   # that may protect against actors trying to probe us: actors we connect to via wireguard who send their response packets (speculatively) to our plaintext IP to see if we accept them.
    #   # but that's fairly low concern, and firewalling by the gateway/NAT helps protect against that already.
    #   ${iptables}/bin/iptables -t mangle -I PREROUTING 1 -i ${name} -m mark --mark 0 -j CONNMARK --restore-mark
    #   ${iptables}/bin/iptables -t mangle -A POSTROUTING  -o ${name} -m mark --mark ${builtins.toString id} -j CONNMARK --save-mark
    # '';

    systemd.services."vpn-${name}" = {
      path = with pkgs; [ iproute2 ];
      serviceConfig = let
        prioMain = id - 200;
        prioFwMark = id - 100;
        mkScript = verb: pkgs.writeShellScript "vpn-${name}-${verb}" ''
          # first, allow all non-default routes (prefix-length != 0) a chance to route the packet.
          # - this allows the wireguard tunnel itself to pass traffic via our LAN gateway.
          # - incidentally, it allows traffic to LAN devices and other machine-local or virtual networks.
          ip rule ${verb} from all lookup main suppress_prefixlength 0 priority ${builtins.toString prioMain}
          # if packet hasn't gone through the wg device yet (fwmark), then move it to the table which will cause it to.
          ip rule ${verb} not from all fwmark ${builtins.toString id} lookup ${builtins.toString id} priority ${builtins.toString prioFwMark}
        '';
      in {
        ExecStart = ''${mkScript "add"}'';
        ExecStop = ''${mkScript "del"}'';
        Type = "oneshot";
        RemainAfterExit = true;
        Restart = "on-failure";
        # it'd be nice if this could depend on the network device we just declared, but there seems no way to do that except via 3rd-party tooling.
      };
    };
  };
in
{
  options = with lib; {
    sane.vpn = mkOption {
      type = types.attrsOf vpnOpts;
      default = {};
    };
  };

  config = let
    configs = lib.mapAttrsToList mkVpnConfig cfg;
    take = f: {
      assertions = f.assertions;
      networking.firewall.checkReversePath = f.networking.firewall.checkReversePath;
      networking.localCommands = f.networking.localCommands;
      systemd.network = f.systemd.network;
      systemd.services = f.systemd.services;
    };
  in take (sane-lib.mkTypedMerge take configs);
}
