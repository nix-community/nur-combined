{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.random-wallpaper;

  jsonConfig = pkgs.writeText "random-wallpaper-config" (builtins.toJSON {
    directories = cfg.directories;
    altMapping = cfg.altMapping;
  });

  script = pkgs.substituteAll {
    name = "random-wallpaper";
    src = ./random_wallpaper.py;
    dir = "bin";
    isExecutable = true;

    inherit jsonConfig;
    inherit (pkgs) feh python3;
    inherit (pkgs.xorg) xrandr;
  };

in {

  options.services.random-wallpaper = {
    enable = mkEnableOption "random desktop wallpaper";

    interval = mkOption {
      default = null;
      type = with types; nullOr str;
      description = ''
        The duration between changing wallpaper image, set to null
        to only set wallpaper when logging in.
        Should be formatted as a duration understood by systemd.
      '';
    };

    directories = mkOption { type = with types; listOf str; };

    altMapping = mkOption {
      default = { };
      type = with types; attrsOf (listOf str);
      example = {
        "1080x1920" = [ "vertical" ];
        "1368x768" = [ "1920x1080" ];
      };
    };
  };

  config = mkIf cfg.enable (mkMerge ([
    {
      home.packages = [ script ];

      systemd.user.services.random-wallpaper = {
        Unit = {
          Description = "Set random desktop wallpaper";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${script}/bin/random-wallpaper";
          IOSchedulingClass = "idle";
        };

        Install = { WantedBy = [ "graphical-session.target" ]; };
      };
    }
    (mkIf (cfg.interval != null) {
      systemd.user.timers.random-wallpaper = {
        Unit = { Description = "Set random desktop wallpaper"; };

        Timer = {
          OnActiveSec = cfg.interval;
          OnUnitActiveSec = cfg.interval;
        };

        Install = { WantedBy = [ "timers.target" ]; };
      };
    })
  ]));

}
