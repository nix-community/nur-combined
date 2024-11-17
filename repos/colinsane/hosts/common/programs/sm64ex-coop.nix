{ config, lib, ... }:
let
  cfg = config.sane.programs.sm64ex-coop;
in
{
  sane.programs.sm64ex-coop = {
    sandbox.net = "all";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    sandbox.whitelistX = true;
    sandbox.extraPaths = [
      "/dev/input"  #< for controllers
    ];

    persist.byStore.plaintext = [
      ".local/share/sm64ex-coop"
    ];
  };

  # LAN play
  networking.firewall.allowedUDPPorts = lib.mkIf cfg.enabled [ 2345 ];
}
