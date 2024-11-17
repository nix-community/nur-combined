{ config, lib, ... }:
let
  cfg = config.sane.programs.sm64coopdx;
in
{
  sane.programs.sm64coopdx = {
    sandbox.net = "all";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDri = true;
    sandbox.whitelistWayland = true;
    # sandbox.whitelistX = true;  #< XXX(2024-11-10): why was this enabled?
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
