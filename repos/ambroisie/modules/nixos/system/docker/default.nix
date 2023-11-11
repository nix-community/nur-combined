# Podman related settings
{ config, lib, ... }:
let
  cfg = config.my.system.docker;
in
{
  options.my.system.docker = with lib; {
    enable = mkEnableOption "docker configuration";
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;

      # Remove unused data on a weekly basis
      autoPrune = {
        enable = true;

        dates = "weekly";

        flags = [
          "--all"
        ];
      };
    };
  };
}
