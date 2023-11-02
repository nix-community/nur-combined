{config, lib, ...}:
{
  networking.ports.zerotierone.enable = true;
  # networking.ports.zerotierone.port = lib.mkDefault 49143;

  services.zerotierone = {
    enable = true;
    inherit (config.networking.ports.zerotierone) port;
    joinNetworks = [
      "e5cd7a9e1c857f07"
    ];
  };
  networking.firewall.trustedInterfaces = [ "ztppi77yi3" ];
}
