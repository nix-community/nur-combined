{ config, lib, pkgs, ... }:
with lib;
{
  # IMPORTANT: make sure you have internet connection before you log 
  # into your computer, otherwise the background fetching process will fail. 
  # of course if you are using a file path instead of a URL, you don't have 
  # to worry about that
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
