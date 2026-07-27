{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.profile.specialisations.gaming;
  notify-send = lib.getExe pkgs.libnotify;

in
{
  environment.systemPackages = cfg.system.extraPkgs;
  hardware = {
    graphics.extraPackages32 = [ pkgs.pkgsi686Linux.libva ];
    steam-hardware.enable = cfg.steam.enableSteamHardware;
  };
  profile = {
    specialisations.gaming.indicator = true;
    predicates.unfreePackages = [
      "steam"
      "steam-run"
      "steam-original"
      "steam-unwrapped"
    ];
  };
  programs = {
    gamemode = {
      enable = true;
      settings = {
        custom = {
          start = "${notify-send} 'GameMode started'";
          end = "${notify-send} 'GameMode ended'";
        };
      };
    };
    steam = {
      enable = cfg.steam.enable;
      gamescopeSession.enable = cfg.steam.enableGamescope;
    };
  };
  services.qbittorrent.enable = lib.mkForce false;
}
