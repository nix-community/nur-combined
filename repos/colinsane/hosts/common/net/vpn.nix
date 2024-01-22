# to add a new OVPN VPN:
# - generate a privkey `wg genkey`
# - add this key to `sops secrets/universal.yaml`
# - upload pubkey to OVPN.com (`cat wg.priv | wg pubkey`)
# - generate config @ OVPN.com
# - copy the Address, PublicKey, Endpoint from OVPN's config

{ config, lib, pkgs, ... }:
let
  def-ovpn = name: { endpoint, publicKey, addrV4, id }: {
    sane.vpn."ovpnd-${name}" = {
      inherit endpoint publicKey addrV4 id;
      privateKeyFile = config.sops.secrets."wg/ovpnd_${name}_privkey".path;
      dns = [
        "46.227.67.134"
        "192.165.9.158"
      ];
    };

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
