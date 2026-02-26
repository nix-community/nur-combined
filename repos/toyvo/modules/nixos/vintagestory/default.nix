{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.vintagestory = {
    enable = lib.mkEnableOption "vintagestory.enable";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.VintagestoryServer;
    };
  };

  config = lib.mkIf (config.vintagestory.enable) {
    systemd.services.vintagestory = {
      description = "Vintage Story Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${config.vintagestory.package}/bin/VintagestoryServer";
        Restart = "always";
      };
    };
  };
}
