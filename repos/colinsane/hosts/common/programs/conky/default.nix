{ config, pkgs, ... }:
{
  sane.programs.conky = {
    fs.".config/conky/conky.conf".symlink.target =
      let
        battery_estimate = pkgs.static-nix-shell.mkBash {
          pname = "battery_estimate";
          src = ./.;
        };
      in pkgs.substituteAll {
        src = ./conky.conf;
        bat = "${battery_estimate}/bin/battery_estimate";
        weather = "timeout 20 ${pkgs.sane-weather}/bin/sane-weather";
      };

    services.conky = {
      description = "conky dynamic desktop background";
      wantedBy = [ "default.target" ];
      # XXX: should be part of graphical-session.target, but whatever mix of greetd/sway
      # i'm using means that target's never reached...
      # wantedBy = [ "graphical-session.target" ];
      # partOf = [ "graphical-session.target" ];

      serviceConfig.ExecStart = "${config.sane.programs.conky.package}/bin/conky";
      serviceConfig.Type = "simple";
      serviceConfig.Restart = "on-failure";
      serviceConfig.RestartSec = "10s";
      # serviceConfig.Slice = "session.slice";

      # don't start conky until after sway
      preStart = ''test -n "$SWAYSOCK"'';
    };
  };
}
