# debugging:
# - enable logs (shows handshake attempts)
#   - `echo module wireguard +p | sane-sudo-redirect /sys/kernel/debug/dynamic_debug/control`
#   - `sudo dmesg --follow`
#     patterns: "Sending keepalive packet to peer NN (N.N.N.N:NNNNN)"
#     patterns: "Sending handshake initiation to peer NN (N.N.N.N:NNNNN)"
# - when wg-doof and wg-ovpns stop routing traffic, restart with:
#   - `systemctl restart netns-doof-wg`
# - handshaking:
#   - `wg show` should *always* show "latest handshake: N", with N < 2 minutes ago.
{ lib, ... }:
let
  portOpts = with lib; types.submodule {
    options = {
      visibleTo.ovpns = mkOption {
        type = types.bool;
        default = false;
        description = ''
          whether to forward inbound traffic on the OVPN vpn port to the corresponding localhost port.
        '';
      };
      visibleTo.doof = mkOption {
        type = types.bool;
        default = false;
        description = ''
          whether to forward inbound traffic on the doofnet vpn port to the corresponding localhost port.
        '';
      };
    };
  };
in
{
  options = with lib; {
    sane.ports.ports = mkOption {
      # add the `visibleTo.{doof,ovpns}` options
      type = types.attrsOf portOpts;
    };
  };

  imports = [
    ./doof.nix
    ./ovpn.nix
    ./wg-home.nix
  ];

  config = {
    networking.domain = "uninsane.org";
    systemd.network.networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig.Address = [
        "205.201.63.12/32"
        "10.78.79.51/22"
      ];
      networkConfig.DNS = [ "10.78.79.1" ];
    };

    sane.ports.openFirewall = true;
    sane.ports.openUpnp = true;
  };
}
