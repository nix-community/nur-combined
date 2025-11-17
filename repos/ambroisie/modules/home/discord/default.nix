{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.discord;
in
{
  options.my.home.discord = with lib; {
    enable = mkEnableOption "discord configuration";

    package = mkPackageOption pkgs "discord" { };
  };

  config = lib.mkIf cfg.enable {
    programs.discord = {
      enable = true;

      inherit (cfg) package;

      settings = {
        # Do not keep me from using the app just to force an update
        SKIP_HOST_UPDATE = true;
      };
    };
  };
}
