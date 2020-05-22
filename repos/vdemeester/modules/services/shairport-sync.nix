{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.shairport-sync;
in
{

  ###### interface

  options = {

    services.shairport-sync = {

      enable = mkOption {
        default = false;
        description = ''
          Enable the shairport-sync daemon.

          Running with a local system-wide or remote pulseaudio server
          is recommended.
        '';
      };

      arguments = mkOption {
        default = "-v -o pa";
        description = ''
          Arguments to pass to the daemon. Defaults to a local pulseaudio
          server.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    /*
    Requires the following in NixOS (or elsewhere).

    services.avahi.enable = true;
    services.avahi.publish.enable = true;
    services.avahi.publish.userServices = true;
    networking.firewall.allowedUDPPortRanges = [ { from = 6001; to = 6101; } ];
    networking.firewall.allowedTCPPorts = [ 5000 ];
    */

    systemd.user.services.shairport-sync = {
      Unit = {
        After = [ "network.target" "sound.target" ];
        Description = "Airplay audio player";
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
      Service = {
        Environment = "PATH=${config.home.profileDirectory}/bin";
        ExecStart = "${pkgs.shairport-sync}/bin/shairport-sync ${cfg.arguments}";
        ExecStop = "${pkgs.procps}/bin/pkill shairport-sync";
        Type = "simple";
      };
    };
  };
}
