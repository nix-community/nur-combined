{config, lib, ...}:
lib.mkIf config.services.zerotierone.enable {
  networking.ports.zerotierone.enable = true;
  # networking.ports.zerotierone.port = lib.mkDefault 49143;

  services.zerotierone = {
    inherit (config.networking.ports.zerotierone) port;
    joinNetworks = [
      "e5cd7a9e1c857f07"
    ];
  };
  networking.firewall.trustedInterfaces = [ "ztppi77yi3" ];
}
