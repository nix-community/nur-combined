{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let

  cfg = config.services.swayidle;

  mkTimeout =
    t:
    [
      "timeout"
      (toString t.timeout)
      (escapeShellArg t.command)
    ]
    ++ optionals (t.resumeCommand != null) [
      "resume"
      (escapeShellArg t.resumeCommand)
    ];

  mkEvent = e: [
    e.event
    (escapeShellArg e.command)
  ];

  args = cfg.extraArgs ++ (concatMap mkTimeout cfg.timeouts) ++ (concatMap mkEvent cfg.events);

in
{

  options.services.swayidle =
    let

      timeoutModule = _: {
        options = {
          timeout = mkOption {
            type = types.ints.positive;
            example = 60;
            description = "Timeout in seconds.";
          };

          command = mkOption {
            type = types.str;
            description = "Command to run after timeout seconds of inactivity.";
          };

          resumeCommand = mkOption {
            type = with types; nullOr str;
            default = null;
            description = "Command to run when there is activity again.";
          };
        };
      };

      eventModule = _: {
        options = {
          event = mkOption {
            type = types.enum [
              "before-sleep"
              "after-resume"
              "lock"
              "unlock"
            ];
            description = "Event name.";
          };

          command = mkOption {
            type = types.str;
            description = "Command to run when event occurs.";
          };
        };
      };

    in
    {
      enable = mkEnableOption "idle manager for Wayland";

      package = mkOption {
        type = types.package;
        default = pkgs.swayidle;
        defaultText = literalExpression "pkgs.swayidle";
        description = "Swayidle package to install.";
      };

      timeouts = mkOption {
        type = with types; listOf (submodule timeoutModule);
        default = [ ];
        example = literalExpression ''
          [
            { timeout = 60; command = "noctalia-shell ipc call lockScreen toggle"; }
            { timeout = 90; command = "${pkgs.systemd}/bin/systemctl suspend"; }
          ]
        '';
        description = "List of commands to run after idle timeout.";
      };

      events = mkOption {
        type = with types; listOf (submodule eventModule);
        default = [ ];
        example = literalExpression ''
          [
            { event = "before-sleep"; command = "${pkgs.swaylock}/bin/swaylock -fF"; }
            { event = "lock"; command = "lock"; }
          ]
        '';
        description = "Run command on occurrence of a event.";
      };

      extraArgs = mkOption {
        type = with types; listOf str;
        default = [ ];
        description = "Extra arguments to pass to swayidle.";
      };

      systemdTarget = mkOption {
        type = types.str;
        default = "graphical-session.target";
        example = "sway-session.target";
        description = ''
          Systemd target to bind to.
        '';
      };

    };

  config = mkIf cfg.enable {

    systemd.user.services.swayidle = {
      bindsTo = [ "graphical-session.target" ];
      partOf = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      requisite = [ "graphical-session.target" ];
      wantedBy = [ cfg.systemdTarget ];

      serviceConfig = {
        Type = "simple";
        Restart = "always";
        # swayidle executes commands using "sh -c", so the PATH needs to contain a shell.
        Environment = [
          "PATH=${
            let
              genGetFormattedDate =
                { format, type }:
                {
                  stdenv,
                  writeTextDir,
                }:
                stdenv.mkDerivation (finalAttrs: {
                  name = "simple-date";
                  src = writeTextDir "src/get-date.c" ''
                    #include <stdio.h>
                    #include <sys/time.h>
                    #include <time.h>

                    int main() {
                        struct timeval tv;
                        struct tm *tm;
                        char buffer[30];

                        gettimeofday(&tv, NULL);
                        tm = localtime(&tv.tv_sec);
                        strftime(buffer, 30, "${format}", tm);
                        printf("%s\n", buffer);

                        return 0;
                    }
                  '';

                  buildPhase = ''
                    mkdir -p $out
                    gcc $src/src/get-date.c
                  '';
                  installPhase = ''
                    install -Dm555 a.out $out/bin/get-${type}
                  '';
                });
            in
            (
              [
                {
                  format = "%A, %B %d";
                  type = "date";
                }
                {
                  format = "%R";
                  type = "time";
                }
              ]
              |> map genGetFormattedDate
              |> map (i: pkgs.callPackage i { })
              |> makeBinPath
            )
          }"
          "WAYLAND_DISPLAY=wayland-1"
        ];
        ExecStart = "${cfg.package}/bin/swayidle -w ${concatStringsSep " " args}";
      };

    };
  };
}
