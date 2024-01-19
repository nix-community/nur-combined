{ config, lib, pkgs, ... }:

# to add a new OVPN VPN:
# - generate a privkey `wg genkey`
# - add this key to `sops secrets/universal.yaml`
# - upload pubkey to OVPN.com (`cat wg.priv | wg pubkey`)
# - generate config @ OVPN.com
# - copy the Address, PublicKey, Endpoint from OVPN's config
#
# debugging:
# - `journalctl -u systemd-networkd`
#
# docs:
# - wireguard (nixos): <https://nixos.wiki/wiki/WireGuard#Setting_up_WireGuard_with_systemd-networkd>
# - wireguard (arch): <https://wiki.archlinux.org/title/WireGuard>
let
  def-wg-vpn = name: { endpoint, publicKey, addrV4, bridgeAddrV4, dns, privateKeyFile, id }: {
    # id is a number < 2^15 which has to be unique in iproute and as a fwmark.
    # my own convention is > 10000
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

    systemd.network.netdevs."99-br-${name}" = {
      netdevConfig.Kind = "bridge";
      netdevConfig.Name = "br-${name}";
    };
    systemd.network.networks."51-br-${name}" = {
      matchConfig.Name = "br-${name}";
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
  def-ovpn = name: { endpoint, publicKey, addrV4, id }: (def-wg-vpn "ovpnd-${name}" {
    inherit endpoint publicKey addrV4;
    id = 10000 + id;
    privateKeyFile = config.sops.secrets."wg/ovpnd_${name}_privkey".path;
    bridgeAddrV4 = "10.20.${builtins.toString id}.1/24";
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
  (def-ovpn "us" {
    endpoint = "vpn31.prd.losangeles.ovpn.com:9929";
    publicKey = "VW6bEWMOlOneta1bf6YFE25N/oMGh1E1UFBCfyggd0k=";
    id = 1;
    addrV4 = "172.27.237.218";
    # addrV6 = "fd00:0000:1337:cafe:1111:1111:ab00:4c8f";
  })
  # TODO: us-atl disabled until i can give it a different link-local address and wireguard key than us-mi
  # (def-ovpn "us-atl" {
  #   endpoint = "vpn18.prd.atlanta.ovpn.com:9929";
  #   publicKey = "Dpg/4v5s9u0YbrXukfrMpkA+XQqKIFpf8ZFgyw0IkE0=";
  #   address = [
  #     "172.21.182.178/32"
  #     "fd00:0000:1337:cafe:1111:1111:cfcb:27e3/128"
  #   ];
  # })
  (def-ovpn "us-mi" {
    endpoint = "vpn34.prd.miami.ovpn.com:9929";
    publicKey = "VtJz2irbu8mdkIQvzlsYhU+k9d55or9mx4A2a14t0V0=";
    id = 2;
    addrV4 = "172.21.182.178";
    # addrV6 = "fd00:0000:1337:cafe:1111:1111:cfcb:27e3";
  })
  (def-ovpn "ukr" {
    endpoint = "vpn96.prd.kyiv.ovpn.com:9929";
    publicKey = "CjZcXDxaaKpW8b5As1EcNbI6+42A6BjWahwXDCwfVFg=";
    id = 3;
    addrV4 = "172.18.180.159";
    # addrV6 = "fd00:0000:1337:cafe:1111:1111:ec5c:add3";
  })
]
