{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.abszero.programs.steam;
in

{
  options.abszero.programs.steam.enable = mkEnableOption "Steam client";

  config.programs = mkIf cfg.enable {
    steam = {
      enable = true;
      package = pkgs.steam.override {
        # extraArgs = "-forcedesktopscaling=2";
        # https://github.com/YaLTeR/niri/wiki/Application-Issues#steam
        extraArgs = "-system-composer";
      };
      remotePlay.openFirewall = true;
      gamescopeSession.enable = true;
    };
    
    # Let gamescope renice itself
    gamescope.capSysNice = true;
  };
}
