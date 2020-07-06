{ config, lib, pkgs, ... }:

with lib; {
  services.mpd = {
    enable = true;
    # FIXME put this into an option
    musicDirectory = "/net/sakhalin.home/export/gaia/music";
    network.listenAddress = "any";
    extraConfig = ''
      audio_output {
        type    "pulse"
        name    "Local MPD"
      }
    '';
  };
  services.mpdris2 = {
    enable = true;
    mpd.host = "127.0.0.1";
  };
  home.packages = with pkgs; [
    ario
    mpc_cli
    ncmpcpp
  ];
}
