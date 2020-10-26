{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.gnome-keyring-daemon;

in {
  meta.maintainers = [ maintainers.rycee ];

  options = {
    services.gnome-keyring-daemon = {
      enable = mkEnableOption "GNOME Keyring";

      components = mkOption {
        type = types.listOf (types.enum [ "pkcs11" "secrets" "ssh" ]);
        default = [ ];
        description = ''
          The GNOME keyring components to start. If empty then the
          default set of components will be started.
        '';
      };

      executable = mkOption {
        type = types.str;
        default = "${pkgs.gnome3.gnome-keyring}/bin/gnome-keyring-daemon";
        example = "/run/wrappers/bin/gnome-keyring-daemon";
        description = ''
          The gnome-keyring-daemon needs to have the cap_ipc_lock capability, 
          otherwise you get error messages like these:
          https://unix.stackexchange.com/questions/112030/gnome-keyring-daemon-insufficient-process-capabilities-unsecure-memory-might-g

          NixOS can create the wrapper for you by enabling:

              services.gnome3.keyring-daemon.enable = true;

          If you're using sway you need to disable the PAM service, since then
          you need DBus to work:

              security.pam.services.login.enableGnomeKeyring = mkForce false;
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.gnome-keyring = {
      Unit = {
        Description = "GNOME Keyring";
        PartOf = [ "graphical-session-pre.target" ];
      };

      Service = {
        ExecStart = let
          args = concatStringsSep " " ([ "--start" "--foreground" ]
            ++ optional (cfg.components != [ ])
            ("--components=" + concatStringsSep "," cfg.components));
        in "${cfg.executable} ${args}";
        Restart = "on-abort";
      };

      Install = { WantedBy = [ "graphical-session-pre.target" ]; };
    };
  };
}
