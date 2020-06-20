{ config, lib, pkgs, ... }:
with lib;
{
  options.fetchBackground = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''whether to enable fetching a background from the fetch'';
    };
    url = mkOption {
      type = types.str;
      default = "https://source.unsplash.com/random";
      description = ''url to fetch background from'';
    };
  };
  config = {
    services.xserver.displayManager.sessionCommands = mkIf config.fetchBackground.enable ''
      ${pkgs.feh}/bin/feh --bg-scale ${config.fetchBackground.url}
    '';
  };
}
