# origin https://github.com/NullCub3/lemurs/blob/nixosmodule-dev/nix/lemurs-module.nix
{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.lemurs;
  settingsFormat = pkgs.formats.toml { };
  inherit (config.services.displayManager) sessionData;

  inherit (lib)
    mkDefault
    mkEnableOption
    mkOption
    mkPackageOption
    ;
in
{
  options.services.lemurs = {
    enable = mkEnableOption "the Lemurs Display Manager";
    package = mkPackageOption pkgs "lemurs" { };
    settings = mkOption {
      default = { };
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          tty = lib.mkOption {
            type = lib.types.int;
            default = 2;
            defaultText = lib.literalExpression "2";
            description = ''
              The tty which contains lemurs. This has to be mirrored in the lemurs.service
            '';
          };
          cache_path = lib.mkOption {
            type = lib.types.str;
            default = "/var/cache/lemurs";
            defaultText = lib.literalExpression "/var/cache/lemurs";
            description = ''
              cache
            '';
          };
          wayland = {
            scripts_path = lib.mkOption {
              type = lib.types.str;
              default = "/etc/lemurs/wayland";
              defaultText = lib.literalExpression "/etc/lemurs/wayland";
              description = ''
                Path to the directory where the startup scripts for the Wayland sessions are
                found
              '';
            };
            wayland_sessions_path = lib.mkOption {
              type = lib.types.str;
              default = "${sessionData.desktops.outPath}/share/wayland-sessions";
              defaultText = lib.literalExpression "/etc/lemurs/wayland";
              description = ''
                Path to the directory where the startup scripts for the Wayland sessions are
                found
              '';
            };
            # x11 etc no needed to me
          };
        };
      };
    };
  };

  config =
    let
      tty = "tty${toString (cfg.settings.tty)}";
    in
    lib.mkIf cfg.enable {
      systemd.tmpfiles.rules = [
        "d '${cfg.settings.cache_path}' - - - - -"
      ];

      security.pam.services = {
        lemurs.text = ''
          auth include login
          account include login
          session include login
          password include login
        '';

        # See https://github.com/coastalwhite/lemurs/issues/166
        login = {
          setLoginUid = false;
          enableGnomeKeyring = config.services.gnome.gnome-keyring.enable;
        };
      };

      environment.sessionVariables = {
        XDG_SEAT = "seat0";
        XDG_VTNR = toString tty;
      };

      services.displayManager = {
        enable = mkDefault true;
      };

      environment.etc."lemurs/config.toml".source = (settingsFormat.generate "lemurs.toml" cfg.settings);
      systemd = {
        defaultUnit = "graphical.target";
        services = {
          "autovt@${tty}".enable = false;

          lemurs = {
            aliases = [ "display-manager.service" ];

            unitConfig = {
              Wants = [
                "systemd-user-sessions.service"
              ];

              After = [
                "systemd-user-sessions.service"
                "plymouth-quit-wait.service"
                "getty@${tty}.service"
              ];

              Conflicts = [
                "getty@${tty}.service"
              ];
            };

            serviceConfig = {
              ExecStart =
                let
                  args = lib.cli.toGNUCommandLineShell { } {
                    wlsessions = cfg.settings.wayland.wayland_sessions_path;
                  };
                in
                "${cfg.package}/bin/lemurs ${args}";

              StandardInput = "tty";
              TTYPath = "/dev/${tty}";
              TTYReset = "yes";
              TTYVHangup = "yes";
              Type = "idle";
            };

            restartIfChanged = false;
            wantedBy = [ "graphical.target" ];
          };
        };
      };

    };
}
