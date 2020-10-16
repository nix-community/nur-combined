{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.random-wallpaper;

  jsonConfig = pkgs.writeText "random-wallpaper-config" (builtins.toJSON {
    directories = cfg.directories;
    altMapping = cfg.altMapping;
    backend = cfg.backend;
  });

  script = pkgs.substituteAll {
    name = "random-wallpaper";
    src = ./random_wallpaper.py;
    dir = "bin";
    isExecutable = true;

    inherit jsonConfig;
    inherit (pkgs) python3;
  };

  wrapped = pkgs.symlinkJoin {
    name = "random-wallpaper";
    paths = [ script ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/random-wallpaper \
        --prefix PATH : ${makeBinPath (with pkgs;
          []
          ++ optionals (cfg.backend == "xorg") [feh xorg.xrandr]
          ++ optional (cfg.backend == "sway") sway
        )}
    '';
  };

in {

  options.services.random-wallpaper = {
    enable = mkEnableOption "random desktop wallpaper";

    backend = mkOption {
      default = "xorg";
      type = types.enum ["xorg" "sway"];
    };

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
      home.packages = [ wrapped ];

      systemd.user.services.random-wallpaper = {
        Unit = {
          Description = "Set random desktop wallpaper";
          After = [ "graphical-session-pre.target" ];
          PartOf = [ "graphical-session.target" ];
        };

        Service = {
          Type = "oneshot";
          ExecStart = "${wrapped}/bin/random-wallpaper";
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
