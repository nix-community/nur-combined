{ config, lib, pkgs, ... }:

let
  cfg = config.services.gns3-server;

  settingsFormat = pkgs.formats.ini { };
  configFile = settingsFormat.generate "gns3-server.conf" cfg.settings;

  flags = {
    enableDocker = config.virtualisation.docker.enable;
    enableLibvirtd = config.virtualisation.libvirtd.enable;
  };

in {
  meta.maintainers = [ lib.maintainers.anthonyroussel ];

  options = {
    services.gns3-server = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = lib.mdDoc ''Whether to enable GNS3 Server daemon.'';
      };

      package = lib.mkPackageOptionMD pkgs "gns3-server" {};

      auth = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = lib.mdDoc ''Enable password based HTTP authentication to access the GNS3 server.'';
        };

        user = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "gns3";
          description = lib.mdDoc ''Username used to access the GNS3 server.'';
        };

        passwordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          description = lib.mdDoc ''
            A file containing the password of the SMTP server account.

            This should be a string, not a nix path, since nix paths
            are copied into the world-readable nix store.
          '';
        };
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = settingsFormat.type;
        };
        default = { };
        description = lib.mdDoc ''
          The global options in `config` file in ini format.
        '';
      };

      host = lib.mkOption {
        type = lib.types.str;
        default = "127.0.0.1";
        description = lib.mdDoc ''IP address on which GNS3 Server will listen on.'';
      };

      port = lib.mkOption {
        type = lib.types.port;
        default = 3080;
        description = lib.mdDoc ''Port on which GNS3 Server will listen on.'';
      };

      log = {
        file = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = "/var/log/gns3/server.log";
          description = lib.mdDoc ''Path of the file GNS3 Server should log to.'';
        };

        debug = lib.mkOption {
          default = false;
          type = lib.types.bool;
          description = lib.mdDoc ''Whether to enable debug logging.'';
        };
      };

      tls = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = lib.mdDoc ''Whether to enable TLS encryption.'';
        };

        certFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          example = "/secrets/gns3.crt";
          description = lib.mdDoc ''
            Path to the TLS certificate file. This certificate will
            be offered to, and may be verified by, clients.
          '';
        };

        keyFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          example = "/secrets/gns3.key";
          description = lib.mdDoc "Private key file for the certificate.";
        };
      };

      dynamips = {
        enable = lib.mkEnableOption (lib.mdDoc ''Whether to enable Dynamips support.'');
        package = lib.mkPackageOptionMD pkgs "dynamips" {};
      };

      ubridge = {
        enable = lib.mkEnableOption (lib.mdDoc ''Whether to enable uBridge support.'');
        package = lib.mkPackageOptionMD pkgs "ubridge" {};
      };

      vpcs = {
        enable = lib.mkEnableOption (lib.mdDoc ''Whether to enable VPCS support.'');
        package = lib.mkPackageOptionMD pkgs "vpcs" {};
      };
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages =
      [ cfg.package ]
      ++ lib.optional cfg.dynamips.enable cfg.dynamips.package
      ++ lib.optional cfg.ubridge.enable cfg.ubridge.package
      ++ lib.optional cfg.vpcs.enable cfg.vpcs.package;

    users.groups.ubridge = lib.mkIf cfg.ubridge.enable {};

    security.wrappers.ubridge = lib.mkIf cfg.ubridge.enable {
      capabilities = "cap_net_raw,cap_net_admin=eip";
      group = "ubridge";
      owner = "root";
      permissions = "u=rwx,g=rx,o=r";
      source = "${cfg.ubridge.package}/bin/ubridge";
    };

    users.users.gns3 = {
      name = "gns3";
      group = "gns3";
      description = "GNS3 user";
      isSystemUser = true;
      home = "/var/lib/gns3";
      extraGroups = lib.optional flags.enableDocker "docker"
        ++ lib.optional flags.enableLibvirtd "libvirtd"
        ++ lib.optional cfg.ubridge.enable "ubridge";
    };

    users.groups.gns3 = {};

    services.gns3-server.settings = lib.mkMerge [
      {
        Server = {
          appliances_path = "/var/lib/gns3/appliances";
          configs_path = "/var/lib/gns3/configs";
          images_path = "/var/lib/gns3/images";
          projects_path = "/var/lib/gns3/projects";
          symbols_path = "/var/lib/gns3/symbols";

          ubridge_path = lib.mkIf (cfg.ubridge.enable) "${cfg.ubridge.package}/bin/ubridge";

          auth = if cfg.auth.enable then "True" else "False";
          user = lib.mkIf (cfg.auth.user != null) cfg.auth.user;
          password = lib.mkIf (cfg.auth.passwordFile != null) "@AUTH_PASSWORD@";
        };
      }
      (lib.mkIf (cfg.vpcs.enable) {
        VPCS.vpcs_path = lib.mkIf (cfg.vpcs.enable) "${cfg.vpcs.package}/bin/vpcs";
      })
      (lib.mkIf (cfg.dynamips.enable) {
        Dynamips.dynamips_path = lib.mkIf (cfg.dynamips.enable) "${cfg.dynamips.package}/bin/dynamips";
      })
    ];

    systemd.services.gns3-server = let
      commandArgs = "--config /etc/gns3/gns3_server.conf"
        + " --host ${cfg.host}"
        + " --pid /run/gns3/server.pid"
        + " --port ${toString cfg.port}"
        + lib.optionalString (cfg.log.file != null) " --log ${cfg.log.file}"
        + lib.optionalString (cfg.log.debug) " --debug"
        + lib.optionalString (cfg.tls.enable) " --ssl"
        + lib.optionalString (cfg.tls.certFile != null) " --certfile ${cfg.tls.certFile}"
        + lib.optionalString (cfg.tls.keyFile != null) " --certkey ${cfg.tls.keyFile}"
      ;
    in
    {
      description = "GNS3 Server";

      after = [ "network.target" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];

      preStart = ''
        install -m660 ${configFile} /etc/gns3/gns3_server.conf

        ${lib.optionalString (cfg.auth.passwordFile != null) ''
          ${pkgs.replace-secret}/bin/replace-secret \
            '@AUTH_PASSWORD@' \
            ${cfg.auth.passwordFile} \
            /etc/gns3/gns3_server.conf
        ''}
      '';

      path = lib.optional (flags.enableLibvirtd) pkgs.qemu;

      reloadTriggers = [ configFile ];

      serviceConfig = {
        ConfigurationDirectory = "gns3";
        ConfigurationDirectoryMode = "0750";
        ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
        ExecStart = "${cfg.package}/bin/gns3server ${commandArgs}";
        Group = "gns3";
        LimitNOFILE = 16384;
        LogsDirectory = "gns3";
        LogsDirectoryMode = "0750";
        PIDFile = "/run/gns3/server.pid";
        Restart = "on-failure";
        RestartSec = 5;
        RuntimeDirectory = "gns3";
        StateDirectory = "gns3";
        StateDirectoryMode = "0750";
        User = "gns3";
        WorkingDirectory = "/var/lib/gns3";

        # Hardening
        DeviceAllow = lib.optional (flags.enableLibvirtd) "/dev/kvm";
        DevicePolicy = "closed";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateTmp = true;
        PrivateUsers = true;
        # Don't restrict ProcSubset because python3Packages.psutil requires read access to /proc/stat
        # ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_NETLINK"
          "AF_UNIX"
          "AF_PACKET"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        UMask = "0077";
      };
    };
  };
}
