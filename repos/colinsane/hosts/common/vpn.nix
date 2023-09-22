{ config, lib, pkgs, ... }:

# to add a new OVPN VPN:
# - generate a privkey `wg genkey`
# - add this key to `sops secrets/universal.yaml`
# - upload pubkey to OVPN.com
# - generate config @ OVPN.com
# - copy the Address, PublicKey, Endpoint from OVPN's config
# N.B.: maximum interface name in Linux is 15 characters.
let
  def-wg-vpn = name: { endpoint, publicKey, address, dns, privateKeyFile, extraOptions ? {} }: {
    networking.wg-quick.interfaces."${name}" = {
      inherit address privateKeyFile dns;
      peers = [
        {
          allowedIPs = [
            "0.0.0.0/0"
            "::/0"
          ];
          inherit endpoint publicKey;
        }
      ];
      # to start: `systemctl start wg-quick-${name}`
      autostart = false;
    } // extraOptions;
  };
  def-ovpn = name: { endpoint, publicKey, address }: def-wg-vpn "ovpnd-${name}" {
    inherit endpoint publicKey address;
    privateKeyFile = config.sops.secrets."wg/ovpnd_${name}_privkey".path;
    dns = [
      "46.227.67.134"
      "192.165.9.158"
    ];
  };

  # TODO: this should live in the same file as hosts/modules/wg-home.nix...
  def-servo = def-wg-vpn "vpn-servo" {
    endpoint = config.sane.hosts.by-name."servo".wg-home.endpoint;
    publicKey = config.sane.hosts.by-name."servo".wg-home.pubkey;
    address = [ config.sane.services.wg-home.ip ];
    dns = [
      config.sane.hosts.by-name."servo".wg-home.ip
    ];
    privateKeyFile = config.networking.wireguard.interfaces.wg-home.privateKeyFile;
    extraOptions = {
      # wg-home and vpn-servo interfaces interfere with the result that when connected to both,
      # other wg-home users (lappy-hn, ...) aren't visible. disabling wg-home while the full
      # vpn-servo is active allows wg-home users to be reachable again
      preUp = "${pkgs.iproute2}/bin/ip link set wg-home down";
      postDown = "${pkgs.iproute2}/bin/ip link set wg-home up";
    };
  };
in lib.mkMerge [
  (def-servo)
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
