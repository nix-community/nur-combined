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

  config = mkIf cfg.enable {
    programs.steam = {
      enable = true;
      package = pkgs.steam.override { extraArgs = "-forcedesktopscaling=2"; };
      remotePlay.openFirewall = true;
      gamescopeSession.enable = true;
    };
  };
}
