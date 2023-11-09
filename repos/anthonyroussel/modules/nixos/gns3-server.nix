{ config, lib, pkgs, ... }:

let
  cfg = config.services.gns3-server;

  settingsFormat = pkgs.formats.ini { };
  configFile = settingsFormat.generate "gns3-server.conf" cfg.settings;

in {
  meta = {
    doc = ./gns3-server.md;
    maintainers = [ lib.maintainers.anthonyroussel ];
  };

  options = {
    services.gns3-server = {
      enable = lib.mkEnableOption (lib.mdDoc "GNS3 Server daemon");

      package = lib.mkPackageOptionMD pkgs "gns3-server" { };

      auth = {
        enable = lib.mkEnableOption (lib.mdDoc "password based HTTP authentication to access the GNS3 Server");

        user = lib.mkOption {
          type = lib.types.nullOr lib.types.str;
          default = null;
          example = "gns3";
          description = lib.mdDoc ''Username used to access the GNS3 Server.'';
        };

        passwordFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          example = "/run/secrets/gns3-server-password";
          description = lib.mdDoc ''
            A file containing the password to access the GNS3 Server.

            ::: {.warning}
            This should be a string, not a nix path, since nix paths
            are copied into the world-readable nix store.
            :::
          '';
        };
      };

      settings = lib.mkOption {
        type = lib.types.submodule { freeformType = settingsFormat.type; };
        default = {};
        example = { host = "127.0.0.1"; port = 3080; };
        description = lib.mdDoc ''
          The global options in `config` file in ini format.

          Refer to <https://docs.gns3.com/docs/using-gns3/administration/gns3-server-configuration-file/>
          for all available options.
        '';
      };

      log = {
        file = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = "/var/log/gns3/server.log";
          description = lib.mdDoc ''Path of the file GNS3 Server should log to.'';
        };

        debug = lib.mkEnableOption (lib.mdDoc "debug logging");
      };

      ssl = {
        enable = lib.mkEnableOption (lib.mdDoc "SSL encryption");

        certFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          example = "/var/lib/gns3/ssl/server.pem";
          description = lib.mdDoc ''
            Path to the SSL certificate file. This certificate will
            be offered to, and may be verified by, clients.
          '';
        };

        keyFile = lib.mkOption {
          type = lib.types.nullOr lib.types.path;
          default = null;
          example = "/var/lib/gns3/ssl/server.key";
          description = lib.mdDoc "Private key file for the certificate.";
        };
      };

      dynamips = {
        enable = lib.mkEnableOption (lib.mdDoc ''Whether to enable Dynamips support.'');
        package = lib.mkPackageOptionMD pkgs "dynamips" { };
      };

      ubridge = {
        enable = lib.mkEnableOption (lib.mdDoc ''Whether to enable uBridge support.'');
        package = lib.mkPackageOptionMD pkgs "ubridge" { };
      };

      vpcs = {
        enable = lib.mkEnableOption (lib.mdDoc ''Whether to enable VPCS support.'');
        package = lib.mkPackageOptionMD pkgs "vpcs" { };
      };
    };
  };

  config = let
    flags = {
      enableDocker = config.virtualisation.docker.enable;
      enableLibvirtd = config.virtualisation.libvirtd.enable;
    };

  in lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.ssl.enable -> cfg.ssl.certFile != null;
        message = "Please provide a certificate to use for SSL encryption.";
      }
      {
        assertion = cfg.ssl.enable -> cfg.ssl.keyFile != null;
        message = "Please provide a private key to use for SSL encryption.";
      }
      {
        assertion = cfg.auth.enable -> cfg.auth.user != null;
        message = "Please provide a username to use for HTTP authentication.";
      }
      {
        assertion = cfg.auth.enable -> cfg.auth.passwordFile != null;
        message = "Please provide a password file to use for HTTP authentication.";
      }
    ];

    users.groups.ubridge = lib.mkIf cfg.ubridge.enable { };

    security.wrappers.ubridge = lib.mkIf cfg.ubridge.enable {
      capabilities = "cap_net_raw,cap_net_admin=eip";
      group = "ubridge";
      owner = "root";
      permissions = "u=rwx,g=rx,o=r";
      source = lib.getExe cfg.ubridge.package;
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

    users.groups.gns3 = { };

    services.gns3-server.settings = lib.mkMerge [
      {
        Server = {
          appliances_path = lib.mkDefault "/var/lib/gns3/appliances";
          configs_path = lib.mkDefault "/var/lib/gns3/configs";
          images_path = lib.mkDefault "/var/lib/gns3/images";
          projects_path = lib.mkDefault "/var/lib/gns3/projects";
          symbols_path = lib.mkDefault "/var/lib/gns3/symbols";
        };
      }
      (lib.mkIf (cfg.ubridge.enable) {
        Server.ubridge_path = lib.mkDefault (lib.getExe cfg.ubridge.package);
      })
      (lib.mkIf (cfg.auth.enable) {
        Server = {
          auth = lib.mkDefault (lib.boolToString cfg.auth.enable);
          user = lib.mkDefault cfg.auth.user;
          password = lib.mkDefault "@AUTH_PASSWORD@";
        };
      })
      (lib.mkIf (cfg.vpcs.enable) {
        VPCS.vpcs_path = lib.mkDefault (lib.getExe cfg.vpcs.package);
      })
      (lib.mkIf (cfg.dynamips.enable) {
        Dynamips.dynamips_path = lib.mkDefault (lib.getExe cfg.dynamips.package);
      })
    ];

    systemd.services.gns3-server = let
      commandArgs = lib.cli.toGNUCommandLineShell { } {
        config = "/run/gns3/gns3_server.conf";
        pid = "/run/gns3/server.pid";
        log = cfg.log.file;
        ssl = cfg.ssl.enable;
        # These are implicitly not set if `null`
        certfile = cfg.ssl.certFile;
        certkey = cfg.ssl.keyFile;
      };
    in
    {
      description = "GNS3 Server";

      after = [ "network.target" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];

      preStart = ''
        install -m660 ${configFile} /run/gns3/gns3_server.conf

        ${lib.optionalString (cfg.auth.passwordFile != null) ''
          ${pkgs.replace-secret}/bin/replace-secret \
            '@AUTH_PASSWORD@' \
            ${cfg.auth.passwordFile} \
            /run/gns3/gns3_server.conf
        ''}
      '';

      path = lib.optional flags.enableLibvirtd pkgs.qemu;

      reloadTriggers = [ configFile ];

      serviceConfig = {
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
        DeviceAllow = lib.optional flags.enableLibvirtd "/dev/kvm";
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
