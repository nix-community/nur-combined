{ ... }:
{
  flake.modules.nixos.oo7-session =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.services.oo7-session;
      user = config.identity.user;
      credential = "oo7.keyring-encryption-password";
      settings = pkgs.writeText "oo7-session.json" (
        builtins.toJSON {
          uid = config.users.users.${user}.uid;
          default_keyring = cfg.defaultKeyring;
          required_keyrings = cfg.requiredKeyrings;
          busctl = "${pkgs.systemd}/bin/busctl";
          systemctl = "${pkgs.systemd}/bin/systemctl";
          systemd_creds = "${pkgs.systemd}/bin/systemd-creds";
          ask_password = "${pkgs.systemd}/bin/systemd-ask-password";
        }
      );
      helper = pkgs.writeShellApplication {
        name = "oo7-session";
        text = ''
          exec ${pkgs.python3}/bin/python3 ${../script/oo7-session.py} --config ${settings} "$@"
        '';
      };
    in
    {
      options.services.oo7-session = {
        package = lib.mkOption {
          type = lib.types.package;
          readOnly = true;
          default = helper;
          description = "Helper for credential registration, backup, and readiness checks.";
        };
        defaultKeyring = lib.mkOption {
          type = lib.types.strMatching "[A-Za-z0-9_-]+";
          default = "login";
          description = "Keyring filename stem to use for the default collection.";
        };
        requiredKeyrings = lib.mkOption {
          type = lib.types.listOf (lib.types.strMatching "[A-Za-z0-9_-]+");
          default = [ ];
          description = "Other keyrings that must exist and unlock before applications start.";
        };
      };

      config = {
        assertions = [
          {
            assertion = pkgs.oo7-server.version == "0.6.0";
            message = "Check the oo7 default-collection patch before changing its version.";
          }
          {
            assertion = config.users.users.${user}.uid != null;
            message = "Set a fixed UID before enabling oo7 host credentials.";
          }
        ];

        # oo7 0.6.0 selects the default by filename and can create an empty Login.
        nixpkgs.overlays = [
          (_final: prev: {
            oo7-server = prev.oo7-server.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [ ../pkgs/patches/oo7-session-init.patch ];
              postPatch = (old.postPatch or "") + ''
                substituteInPlace src/service/mod.rs \
                  --replace-fail 'name.eq_ignore_ascii_case(Self::LOGIN_ALIAS)' \
                    'name.eq_ignore_ascii_case(${builtins.toJSON cfg.defaultKeyring})'
              '';
            });
          })
        ];

        services.gnome.gnome-keyring.enable = lib.mkForce false;
        services.oo7.enable = lib.mkForce true;
        security.pam.services = lib.genAttrs [ "ly" "login" ] (_: {
          enableGnomeKeyring = lib.mkForce false;
          oo7.enable = lib.mkForce false;
        });
        environment.systemPackages = [ helper ];

        systemd.user.services = {
          oo7-daemon = {
            # A package alias resolves to a store path and bypasses this unit's drop-in.
            aliases = [ "dbus-org.freedesktop.secrets.service" ];
            wantedBy = lib.mkForce [ "niri.service" ];
            after = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            unitConfig = {
              ConditionUser = user;
              Upholds = "vicinae-server.service";
              StartLimitIntervalSec = 300;
              StartLimitBurst = 3;
            };
            serviceConfig = {
              Type = "dbus";
              BusName = "org.freedesktop.secrets";
              ImportCredential = lib.mkForce "";
              LoadCredentialEncrypted = "${credential}:%h/.config/credstore.encrypted/${credential}";
              ExecCondition = "${lib.getExe helper} condition";
              ExecStartPre = "${lib.getExe helper} prepare";
              ExecStartPost = "${lib.getExe helper} post-start";
              TimeoutStartSec = 90;
              RestartSec = 5;
            };
          };
          vicinae-server = {
            wantedBy = lib.mkForce [ ];
            bindsTo = [ "oo7-daemon.service" ];
            after = [ "oo7-daemon.service" ];
            partOf = [ "graphical-session.target" ];
            serviceConfig.ExecStartPre = "${lib.getExe helper} ready";
          };
        };
      };
    };
}
