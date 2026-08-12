{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.protonmail-bridge;
  stateDir = "/var/lib/protonmail-bridge";
in
{
  # The upstream nixpkgs module targets graphical sessions (wantedBy = graphical-session.target)
  # and does no user/UID setup. Disable it so our system-service replacement owns the namespace.
  disabledModules = [ "services/mail/protonmail-bridge.nix" ];

  options.services.protonmail-bridge = {
    enable = lib.mkEnableOption "ProtonMail Bridge headless SMTP relay";

    package = lib.mkPackageOption pkgs "protonmail-bridge" { };

    uid = lib.mkOption {
      type = lib.types.int;
      default = config.ids.uids."protonmail-bridge";
      description = "Pinned UID for the protonmail-bridge user (must be < 400).";
    };

    gid = lib.mkOption {
      type = lib.types.int;
      default = config.ids.gids."protonmail-bridge";
      description = "Pinned GID for the protonmail-bridge group.";
    };

    logLevel = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "panic"
          "fatal"
          "error"
          "warn"
          "info"
          "debug"
        ]
      );
      default = null;
      description = "Log level passed to --log-level. Null uses the bridge default.";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.protonmail-bridge = {
      uid = cfg.uid;
      isSystemUser = true;
      group = "protonmail-bridge";
      home = stateDir;
      createHome = true;
    };
    users.groups.protonmail-bridge.gid = cfg.gid;

    # Run as root to do the one-time interactive login.
    # When prompted for a keyring password, leave it empty so the service
    # can auto-unlock headlessly on every subsequent start.
    environment.systemPackages = [
      cfg.package
      (pkgs.writeShellScriptBin "protonmail-bridge-setup" ''
        exec ${pkgs.util-linux}/bin/runuser -u protonmail-bridge -- \
          env \
          HOME=${stateDir} \
          XDG_DATA_HOME=${stateDir}/.local/share \
          XDG_CONFIG_HOME=${stateDir}/.config \
          XDG_CACHE_HOME=${stateDir}/.cache \
          XDG_RUNTIME_DIR=/run/protonmail-bridge \
          ${pkgs.dbus}/bin/dbus-run-session \
          --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon \
          -- \
          ${lib.getExe cfg.package} --cli "$@"
      '')
    ];

    systemd.services.protonmail-bridge = {
      description = "ProtonMail Bridge headless SMTP relay";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        User = "protonmail-bridge";
        Group = "protonmail-bridge";
        StateDirectory = "protonmail-bridge";
        RuntimeDirectory = "protonmail-bridge";
        RuntimeDirectoryMode = "0700";
        Restart = "on-failure";
        RestartSec = "10s";
      };

      environment = {
        HOME = stateDir;
        XDG_DATA_HOME = "${stateDir}/.local/share";
        XDG_CONFIG_HOME = "${stateDir}/.config";
        XDG_CACHE_HOME = "${stateDir}/.cache";
        XDG_RUNTIME_DIR = "/run/protonmail-bridge";
      };

      script =
        let
          logLevel = lib.optionalString (cfg.logLevel != null) " --log-level ${cfg.logLevel}";
        in
        ''
          exec ${pkgs.dbus}/bin/dbus-run-session \
            --dbus-daemon=${pkgs.dbus}/bin/dbus-daemon \
            -- \
            ${lib.getExe cfg.package} --noninteractive${logLevel}
        '';
    };
  };
}
