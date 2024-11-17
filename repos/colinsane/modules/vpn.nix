# debugging:
# - `journalctl -u systemd-networkd`
# - `networkctl --help`
#
# docs:
# - wireguard (nixos): <https://nixos.wiki/wiki/WireGuard#Setting_up_WireGuard_with_systemd-networkd>
# - wireguard (arch): <https://wiki.archlinux.org/title/WireGuard>
#
# to route all internet traffic through a VPN endpoint, run `sane-vpn up ${vpnName}`
# to route an application's traffic through a VPN: `sane-vpn do ${vpnName} ${command[@]}`
# to show the routing table: `ip rule`
# to show the NAT rules used for bridging: `sudo iptables -t nat --list-rules -v`
# to force a peer address change (e.g. DNS change): `wg set "${interface}" peer "${publicKey}" endpoint "${endpoint}"`
#
# the rough idea here is:
# 1. each VPN has an IP address: if we originate a packet, and the source address is the VPN's address, then it gets routed over the VPN trivially.
# 2a. create a separate routing table for each VPN, with table id = ID.
# 2b. if a packet enters the VPN's table then it will be routed via the VPN.
# 2c. to apply a VPN to all internet traffic, system-wide, a rule is added that forces each packet to enter that VPN's routing table.
#     - that's done with `systemctl start vpn-$VPN`.
#     - the VPN acts as the default route. so traffic destined to e.g. a LAN device do not traverse the VPN in this case. only internet traffic is VPN'd.
# 3. to apply a VPN to internet traffic selectively, just proxy an applications traffic into the VPN device
#   3a. use a network namespace and a userspace TCP stack (e.g. pasta/slirp4netns).
#   3b. attach the VPN device to a bridge device, then connect that to a network namespace by using a veth pair.
#   3c. juse use `bunpen`, which abstracts the above options.

{ config, lib, sane-lib, ... }:
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
      fwmark = mkOption {
        type = types.int;
        internal = true;
      };
      # priority*: used externally, by e.g. `sane-vpn`
      priorityMain = mkOption {
        type = types.int;
        internal = true;
      };
      priorityFwMark = mkOption {
        type = types.int;
        internal = true;
      };
      isDefault = mkOption {
        type = types.bool;
        description = ''
          read-only value: set based on whichever VPN has the lowest id.
        '';
        internal = true;
      };
      endpoint = mkOption {
        type = types.str;
        description = ''
          host:port which hosts the other end of the VPN.
          e.g. "vpn.example.com:55280"
        '';
      };
      keepalive = mkOption {
        type = types.bool;
        default = false;
        description = ''
          whether to send periodic packets to keep the NAT alive.
          this should only be needed if you want to receive unprompted inbound packets.
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
      subnetV4 = mkOption {
        type = types.nullOr types.str;
        description = ''
          subnet dictating the range of IPs which should ALWAYS be routed through this VPN, no matter the system-wide settings.
        '';
        example = "24";
        default = null;
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
      isDefault = builtins.all (other: config.id <= other.id) (builtins.attrValues cfg);
      fwmark = config.id + 10000;
      priorityMain = config.id + 100;
      priorityFwMark = config.id + 300;
    };
  });
  mkVpnConfig = name: { addrV4, dns, endpoint, fwmark, id, keepalive, privateKeyFile, publicKey, subnetV4, ... }: {
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
        FirewallMark = fwmark;
      };
      wireguardPeers = [
        ({
          AllowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          Endpoint = endpoint;
          PublicKey = publicKey;
        } // lib.optionalAttrs keepalive {
          PersistentKeepalive = 25;
        })
      ];
    };

    systemd.network.networks."50-${name}" = {
      # see: `man 5 systemd.network`
      matchConfig.Name = name;
      networkConfig.Address = [ "${addrV4}/32" ];
      networkConfig.DNS = dns;
      # TODO: `sane-vpn up <vpn>` should configure DNS to be sent over the VPN
      # DNSDefaultRoute: system DNS queries are sent to this link's DNS server
      # networkConfig.DNSDefaultRoute = true;
      # Domains = ~.: system DNS queries are sent to this link's DNS server
      # networkConfig.Domains = "~.";
      routes = [{
        Table = id;
        Scope = "link";
        Destination = "0.0.0.0/0";
        Source = addrV4;
      }] ++ lib.optionals (subnetV4 != null) [{
        Scope = "link";
        Destination = "${addrV4}/${subnetV4}";
        Source = addrV4;
      }];
      # RequiredForOnline => should `systemd-networkd-wait-online` fail if this network can't come up?
      linkConfig.RequiredForOnline = false;
    };
    systemd.network.config.networkConfig.ManageForeignRoutingPolicyRules = false;

    # linux will drop inbound packets if it thinks a reply to that packet wouldn't exit via the same interface (rpfilter).
    # wg-quick has a solution via `iptables -j CONNMARK`, and that does work for system-wide VPNs,
    # but i couldn't get that to work for netns with SNAT, so set rpfilter to "loose".
    networking.firewall.checkReversePath = "loose";

    # XXX: all my wireguard DNS endpoints are static at the moment, so refresh logic isn't needed.
    # re-enable this should that ever change.
    # N.B.: systemd will still bring up the device and even the peer if it fails to resolve the endpoint.
    # but it seems that it'll try to re-resolve the endpoint again later (unclear how to configure this better).
    # systemd.services."${name}-refresh" = {
    #   # periodically re-apply peers, to ensure DNS mappings stay fresh
    #   # borrowed from <repo:nixos/nixpkgs:nixos/modules/services/networking/wireguard.nix>
    #   wantedBy = [ "network.target" ];
    #   path = [ config.sane.programs.wireguard-tools.package ];
    #   serviceConfig.Restart = "always";
    #   serviceConfig.RestartSec = "60"; #< retry delay when we fail (because e.g. there's no network)
    #   serviceConfig.Type = "simple";
    #   unitConfig.StartLimitIntervalSec = 0;
    #   script = ''
    #     while wg set ${name} peer ${publicKey} endpoint ${endpoint}; do
    #       echo "${name} set to:" "$(wg show ${name} endpoints)"
    #       # in the normal case that DNS resolves, and whatnot, sleep before the next attempt
    #       sleep 180
    #     done
    #   '';
    #   # systemd hardening (systemd-analyze security wg-home-refresh.service)
    #   serviceConfig.AmbientCapabilities = "CAP_NET_ADMIN";
    #   serviceConfig.CapabilityBoundingSet = "CAP_NET_ADMIN";
    #   serviceConfig.LockPersonality = true;
    #   serviceConfig.MemoryDenyWriteExecute = true;
    #   serviceConfig.NoNewPrivileges = true;
    #   serviceConfig.ProtectClock = true;
    #   serviceConfig.ProtectHostname = true;
    #   serviceConfig.RemoveIPC = true;
    #   serviceConfig.RestrictAddressFamilies = "AF_INET AF_INET6 AF_NETLINK";
    #   #VVV this includes anything it reads from, e.g. /bin/sh; /nix/store/...
    #   # see `systemd-analyze filesystems` for a full list
    #   serviceConfig.RestrictFileSystems = "@common-block @basic-api";
    #   serviceConfig.RestrictRealtime = true;
    #   serviceConfig.RestrictSUIDSGID = true;
    #   serviceConfig.SystemCallArchitectures = "native";
    #   serviceConfig.SystemCallFilter = [
    #     "@system-service"
    #     "@sandbox"
    #     "~@chown"
    #     "~@cpu-emulation"
    #     "~@keyring"
    #   ];
    #   serviceConfig.DevicePolicy = "closed";  # only allow /dev/{null,zero,full,random,urandom}
    #   # serviceConfig.DeviceAllow = "/dev/...";
    #   serviceConfig.RestrictNamespaces = true;
    # };

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
