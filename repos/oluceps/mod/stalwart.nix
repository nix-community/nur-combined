{
  flake.modules.nixos.stalwart =
    { config, ... }:
    {
      vaultix.secrets.stalwart = {
        owner = "stalwart";
        mode = "400";
      };
      networking.firewall.allowedTCPPorts = [
        993
        25
        587
        465
        995
        4091
      ];
      systemd.services.stalwart.serviceConfig = {
        EnvironmentFile = config.vaultix.secrets.stalwart.path;
      };
      services.stalwart = {
        enable = true;
      };
    };
}
