{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.swayidle;

  mkTimeout = t:
    [ "timeout" (toString t.timeout) (escapeShellArg t.command) ]
    ++ optionals (t.resumeCommand != null) [
      "resume"
      (escapeShellArg t.resumeCommand)
    ];

  mkEvent = e: [ e.event (escapeShellArg e.command) ];

  args = (concatMap mkTimeout cfg.timeouts) ++ (concatMap mkEvent cfg.events)
    ++ cfg.extraArgs;

in {

  options.services.swayidle = let

    timeoutModule = { ... }: {
      options = {
        timeout = mkOption {
          type = types.ints.positive;
          description = "Timeout in seconds";
          example = 60;
        };

        command = mkOption {
          type = types.str;
          description = "Command to run after timeout seconds of inactivity";
        };

        resumeCommand = mkOption {
          type = with types; nullOr str;
          default = null;
          description = "Command to run when there is activity again";
        };
      };
    };

    eventModule = { ... }: {
      options = {
        event = mkOption {
          type = types.enum [ "before-sleep" "after-resume" "lock" "unlock" ];
        };

        command = mkOption {
          type = types.str;
          description = "Command to run when event occurs";
        };
      };
    };

  in {
    enable = mkEnableOption "Idle manager for Wayland";

    timeouts = mkOption {
      type = with types; listOf (submodule timeoutModule);
      default = [ ];
    };

    events = mkOption {
      type = with types; listOf (submodule eventModule);
      default = [ ];
      example = ''
        [
          { event = "before-sleep"; command = "swaylock"; }
          { event = "lock"; command = "lock"; }
        ]
      '';
    };

    extraArgs = mkOption {
      type = with types; listOf str;
      default = [ ];
    };
  };

  # https://github.com/swaywm/sway/wiki/Systemd-integration#swayidle
  config = mkIf cfg.enable {
    systemd.user.services.swayidle = {
      Unit = {
        Description = "Idle manager for Wayland";
        Documentation = "man:swayidle(1)";
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "simple";
        ExecStart =
          "${pkgs.swayidle}/bin/swayidle -w ${concatStringsSep " " args}";
      };

      Install = { WantedBy = [ "sway-session.target" ]; };
    };
  };

}
