{ config, lib, pkgs, ... }:
let
  cfg = config.my.home.discord;

  jsonFormat = pkgs.formats.json { };
in
{
  options.my.home.discord = with lib; {
    enable = mkEnableOption "discord configuration";

    package = mkPackageOption pkgs "discord" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      cfg.package
    ];

    xdg.configFile."discord/settings.json".source =
      jsonFormat.generate "discord.json" {
        # Do not keep me from using the app just to force an update
        SKIP_HOST_UPDATE = true;
      };
  };
}
