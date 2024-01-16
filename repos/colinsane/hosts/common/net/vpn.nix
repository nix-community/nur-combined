{ config, lib, pkgs, ... }:

# to add a new OVPN VPN:
# - generate a privkey `wg genkey`
# - add this key to `sops secrets/universal.yaml`
# - upload pubkey to OVPN.com (`cat wg.priv | wg pubkey`)
# - generate config @ OVPN.com
# - copy the Address, PublicKey, Endpoint from OVPN's config
# N.B.: maximum interface name in Linux is 15 characters.
#
# debugging:
# - `journalctl -u systemd-networkd`
#
# docs:
# - wireguard (nixos): <https://nixos.wiki/wiki/WireGuard#Setting_up_WireGuard_with_systemd-networkd>
# - wireguard (arch): <https://wiki.archlinux.org/title/WireGuard>
let
  def-wg-vpn = name: { endpoint, publicKey, address, dns, privateKeyFile }: {
    systemd.network.netdevs."99-${name}" = {
      # see: `man 5 systemd.netdev`
      netdevConfig = {
        Kind = "wireguard";
        Name = name;
      };
      wireguardConfig = {
        PrivateKeyFile = privateKeyFile;
        FirewallMark = 51820;
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
      networkConfig.Address = address;
      networkConfig.DNS = dns;
      # DNSDefaultRoute: system DNS queries are sent to this link's DNS server
      networkConfig.DNSDefaultRoute = true;
      # Domains = ~.: system DNS queries are sent to this link's DNS server
      networkConfig.Domains = "~.";
      routingPolicyRules = [
        {
          routingPolicyRuleConfig = {
            # allow all non-default-route rules in the main table to take precedence over our wireguard rules.
            # this allows reaching LAN machines (and the LAN's gateway!) without traversing the VPN.
            SuppressPrefixLength = 0;
            Table = "main";
            Priority = 10000;
          };
        }
        {
          routingPolicyRuleConfig = {
            # redirect any outbound packet not yet marked over to the wireguard table, through which it will enter the wg device.
            #   the wg device will then route it over the tunnel, using the LAN gateway to reach the tunnel endpoint
            #   -- which it can route directly, thanks to the higher-precedent rule above which allows reaching the LAN (and therefore gateway) without tunneling.
            # this defines an ip rule: show it with `ip rule`.
            FirewallMark = 51820;
            InvertRule = true;
            Table = 51820;
            Priority = 10001;
          };
        }
      ];
      routes = [{
        # ovpn.com tunnels don't use a gateway. it's as if this link peers with the entire internet.
        # routeConfig.Gateway = address;
        # routeConfig.GatewayOnLink = true;
        routeConfig.Table = 51820;  #< TODO: use name-based table, per VPN
        routeConfig.Scope = "link";
        routeConfig.Destination = "0.0.0.0/0";
      }];
      # RequiredForOnline => should `systemd-networkd-wait-online` fail if this network can't come up?
      linkConfig.RequiredForOnline = false;
      # ActivationPolicy = "manual" means don't auto-up this interface (default is "up")
      linkConfig.ActivationPolicy = "manual";
    };
  };
  def-ovpn = name: { endpoint, publicKey, address }: (def-wg-vpn "ovpnd-${name}" {
    inherit endpoint publicKey address;
    privateKeyFile = config.sops.secrets."wg/ovpnd_${name}_privkey".path;
    dns = [
      "46.227.67.134"
      "192.165.9.158"
    ];
  }) // {
    sops.secrets."wg/ovpnd_${name}_privkey" = {
      # needs to be readable by systemd-network or else it says "Ignoring network device" and doesn't expose it to networkctl.
      owner = "systemd-network";
    };
  };
in lib.mkMerge [
  {
    networking.firewall.extraCommands = with pkgs; ''
      # wireguard packet marking. without this, rpfilter drops responses from a wireguard VPN
      # because the "reverse path check" fails (i.e. it thinks a response to the packet would go out via a different interface than what the wireguard packet arrived at).
      # debug with e.g. `iptables --list -v -n -t mangle`
      # - and `networking.firewall.logReversePathDrops = true;`, `networking.firewall.logRefusedPackets = true;`
      # - and `journalctl -k` to see dropped packets
      #
      # note that wg-quick also adds a rule to reject non-local traffic from all interfaces EXCEPT the tunnel.
      # that may protect against actors trying to probe us: actors we connect to via wireguard who send their response packets (speculatively) to our plaintext IP to see if we accept them.
      # but that's fairly low concern, and firewalling by the gateway/NAT helps protect against that already.
      ${iptables}/bin/iptables -t mangle -I PREROUTING 1 -j CONNMARK --restore-mark
      ${iptables}/bin/iptables -A POSTROUTING -t mangle -m mark --mark 51820 -j CONNMARK --save-mark
    '';
  }
  (def-ovpn "us" {
    endpoint = "vpn31.prd.losangeles.ovpn.com:9929";
    publicKey = "VW6bEWMOlOneta1bf6YFE25N/oMGh1E1UFBCfyggd0k=";
    address = [
      "172.27.237.218/32"
      "fd00:0000:1337:cafe:1111:1111:ab00:4c8f/128"
    ];
  })
  # NB: us-* share the same wg key and link-local addrs, but distinct public addresses
  (def-ovpn "us-atl" {
    endpoint = "vpn18.prd.atlanta.ovpn.com:9929";
    publicKey = "Dpg/4v5s9u0YbrXukfrMpkA+XQqKIFpf8ZFgyw0IkE0=";
    address = [
      "172.21.182.178/32"
      "fd00:0000:1337:cafe:1111:1111:cfcb:27e3/128"
    ];
  })
  (def-ovpn "us-mi" {
    endpoint = "vpn34.prd.miami.ovpn.com:9929";
    publicKey = "VtJz2irbu8mdkIQvzlsYhU+k9d55or9mx4A2a14t0V0=";
    address = [
      "172.21.182.178/32"
      "fd00:0000:1337:cafe:1111:1111:cfcb:27e3/128"
    ];
  })
  (def-ovpn "ukr" {
    endpoint = "vpn96.prd.kyiv.ovpn.com:9929";
    publicKey = "CjZcXDxaaKpW8b5As1EcNbI6+42A6BjWahwXDCwfVFg=";
    address = [
      "172.18.180.159/32"
      "fd00:0000:1337:cafe:1111:1111:ec5c:add3/128"
    ];
  })
]
