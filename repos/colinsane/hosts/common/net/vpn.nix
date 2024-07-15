# to add a new OVPN VPN:
# - generate a privkey `wg genkey`
# - add this key to `sops secrets/universal.yaml`
# - upload pubkey to OVPN.com (`cat wg.priv | wg pubkey`)
# - generate config @ OVPN.com
# - copy the Address, PublicKey, Endpoint from OVPN's config

{ config, lib, pkgs, ... }:
let
  # N.B.: OVPN issues each key (i.e. device) a different IP (addrV4), and requires you use it.
  # the IP it issues can be used to connect to any of their VPNs.
  # effectively the IP and key map 1-to-1.
  # it seems to still be possible to keep two active tunnels on one device, using the same key/IP address, though.
  def-ovpn = name: { endpoint, publicKey, id }: let
    inherit (config.sane.ovpn) addrV4;
  in {
    sane.vpn."ovpnd-${name}" = lib.mkIf (addrV4 != null) {
      inherit addrV4 endpoint publicKey id;
      privateKeyFile = config.sops.secrets."ovpn_privkey".path;
      dns = [
        "46.227.67.134"
        "192.165.9.158"
        # "2a07:a880:4601:10f0:cd45::1"
        # "2001:67c:750:1:cafe:cd45::1"
      ];
    };

    sops.secrets."ovpn_privkey" = lib.mkIf (addrV4 != null) {
      # needs to be readable by systemd-network or else it says "Ignoring network device" and doesn't expose it to networkctl.
      owner = "systemd-network";
    };
  };
in {
  options = with lib; {
    sane.ovpn.addrV4 = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = ''
        ovpn issues one IP address per device.
        set `null` to disable OVPN for this host.
      '';
    };
  };

  config = lib.mkMerge [
    (def-ovpn "us" {
      endpoint = "vpn31.prd.losangeles.ovpn.com:9929";
      publicKey = "VW6bEWMOlOneta1bf6YFE25N/oMGh1E1UFBCfyggd0k=";
      id = 1;
    })
    (def-ovpn "us-mi" {
      endpoint = "vpn34.prd.miami.ovpn.com:9929";
      publicKey = "VtJz2irbu8mdkIQvzlsYhU+k9d55or9mx4A2a14t0V0=";
      id = 2;
    })
    (def-ovpn "ukr" {
      endpoint = "vpn96.prd.kyiv.ovpn.com:9929";
      publicKey = "CjZcXDxaaKpW8b5As1EcNbI6+42A6BjWahwXDCwfVFg=";
      id = 3;
    })
    # TODO: us-atl disabled until i need it again, i guess.
    # (def-ovpn "us-atl" {
    #   endpoint = "vpn18.prd.atlanta.ovpn.com:9929";
    #   publicKey = "Dpg/4v5s9u0YbrXukfrMpkA+XQqKIFpf8ZFgyw0IkE0=";
    #   id = 4;
    # })
  ];
}
