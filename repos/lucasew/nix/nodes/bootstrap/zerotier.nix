{config, ...}:
{
  networking.ports.zerotierone.enable = true;

  services.zerotierone = {
    enable = true;
    inherit (config.networking.ports.zerotierone) port;
    joinNetworks = [
      "e5cd7a9e1c857f07"
    ];
  };
  networking.firewall.trustedInterfaces = [ "ztppi77yi3" ];
}
