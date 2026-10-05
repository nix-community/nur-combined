{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.fail2ban-rs;
  mylib = import ../../lib { inherit pkgs; };
  myCallPackage = pkgs.newScope (pkgs // mylib);
  defaultPackage = myCallPackage ../../pkgs/fail2ban-rs { };
  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "fail2ban-rs.toml" cfg.settings;

  duration = lib.types.either lib.types.int lib.types.str;
  stateDir = cfg.settings.global.state_dir;
  socketDir = dirOf cfg.settings.global.socket_path;

  jailOptions = {
    freeformType = settingsFormat.type;
    options = {
      enabled = lib.mkOption {
        type = lib.types.bool;
        description = "Whether this jail is active.";
        default = true;
      };

      log_path = lib.mkOption {
        type = lib.types.str;
        description = "Path to the log file to monitor.";
        default = "";
        example = "/var/log/auth.log";
      };

      filter = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = ''
          Patterns with `<HOST>` placeholder. Exactly one `<HOST>` per pattern.
        '';
        default = [ ];
        example = [
          ''sshd\[\d+\]: Failed password for .* from <HOST>''
          ''sshd\[\d+\]: Invalid user .* from <HOST>''
        ];
      };

      max_retry = lib.mkOption {
        type = lib.types.ints.positive;
        description = "Number of failures before banning.";
        default = 5;
      };

      find_time = lib.mkOption {
        type = duration;
        description = "Time window failures are counted in (seconds or duration string like \"10m\").";
        default = "10m";
      };

      ban_time = lib.mkOption {
        type = duration;
        description = "Ban duration (seconds or duration string; -1 = permanent).";
        default = "1h";
      };

      port = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Ports to block (numeric only, e.g. `[ \"22\" ]`).";
        default = [ ];
        example = [
          "22"
        ];
      };

      protocol = lib.mkOption {
        type = lib.types.enum [
          "tcp"
          "udp"
        ];
        description = "Protocol for port matching.";
        default = "tcp";
      };

      log_backend = lib.mkOption {
        type = lib.types.enum [
          "file"
          "systemd"
        ];
        description = "Log source backend.";
        default = "file";
      };

      journalmatch = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "Systemd journal match filters, one expression per entry.";
        default = [ ];
        example = [ "_SYSTEMD_UNIT=sshd.service" ];
      };

      ignoreip = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "IPs/CIDRs to never ban.";
        default = [ ];
        example = [
          "127.0.0.1/8"
          "::1/128"
        ];
      };
    };
  };
in
{
  options.services.fail2ban-rs = {
    enable = lib.mkEnableOption "fail2ban-rs service";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "The fail2ban-rs package to use.";
    };

    path = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      description = ''
        Packages on the daemon PATH. The daemon runs firewall tools, `sh`,
        `journalctl` (log_backend = "systemd") and `curl` (webhooks) by name.
      '';
      default = with pkgs; [
        bash
        coreutils
        nftables
        iptables
        ipset
        systemd
        curl
      ];
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType = settingsFormat.type;
        options = {
          global = {
            state_dir = lib.mkOption {
              type = lib.types.str;
              description = "Directory to persist ban state across restarts.";
              default = "/var/lib/fail2ban-rs/state";
            };

            socket_path = lib.mkOption {
              type = lib.types.str;
              description = "Unix socket path for CLI communication.";
              default = "/run/fail2ban-rs/fail2ban-rs.sock";
            };
          };

          jail = lib.mkOption {
            type = lib.types.attrsOf (lib.types.submodule jailOptions);
            description = "Jail definitions, keyed by jail name.";
            default = { };
            example = {
              sshd = {
                log_path = "/var/log/auth.log";
                filter = [ ''sshd\[\d+\]: Failed password for .* from <HOST>'' ];
                port = [ "22" ];
              };
            };
          };
        };
      };
      description = "The fail2ban-rs configuration. See https://github.com/aejimmi/fail2ban-rs for all options.";
      example = {
        jail.sshd = {
          log_path = "/var/log/auth.log";
          filter = [ ''sshd\[\d+\]: Failed password for .* from <HOST>'' ];
          max_retry = 5;
          find_time = "10m";
          ban_time = "1h";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # the daemon refuses to start with zero jails
    assertions = [
      {
        assertion = cfg.settings.jail != { };
        message = "services.fail2ban-rs.settings.jail must define at least one jail.";
      }
    ];

    # expose the config at the CLI default path so `fail2ban-rs status` & co. work
    environment.etc."fail2ban-rs/config.toml".source = configFile;
    environment.systemPackages = [ cfg.package ];

    systemd.services.fail2ban-rs = {
      description = "fail2ban-rs intrusion prevention system";
      documentation = [ "https://github.com/aejimmi/fail2ban-rs" ];
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      path = cfg.path;

      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/fail2ban-rs run --config ${configFile}";
        ExecReload = "${pkgs.util-linux}/bin/kill -HUP $MAINPID";

        Restart = "on-failure";
        RestartSec = "5s";

        RuntimeDirectory = "fail2ban-rs";
        StateDirectory = "fail2ban-rs";
        ReadWritePaths = [
          (dirOf stateDir)
          socketDir
        ];

        StandardOutput = "journal";
        StandardError = "journal";
        SyslogIdentifier = "fail2ban-rs";

        # firewall + reading root-owned logs
        CapabilityBoundingSet = [
          "CAP_NET_ADMIN"
          "CAP_NET_RAW"
          "CAP_DAC_READ_SEARCH"
        ];

        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [ "@system-service" ];
        UMask = "0077";
      };
    };
  };
}
