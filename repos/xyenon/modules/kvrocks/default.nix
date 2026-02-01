{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.kvrocks;
  format = pkgs.formats.keyValue {
    mkKeyValue =
      let
        mkValueString = v: if lib.isBool v then if v then "yes" else "no" else toString v;
      in
      k: v:
      if lib.isList v then
        lib.concatMapStringsSep "\n" (item: "${k} ${mkValueString item}") v
      else
        "${k} ${mkValueString v}";
  };
  configFile = format.generate "kvrocks.conf" (
    cfg.settings
    // {
      daemonize = "no";
      supervised = "systemd";
    }
  );
in
{
  options = {
    services.kvrocks = {
      enable = lib.mkEnableOption "kvrocks";

      package = lib.mkPackageOption pkgs "nur.repos.xyenon.kvrocks" { };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = format.type;

          options = {
            bind = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              description = "The address to bind to.";
            };

            port = lib.mkOption {
              type = lib.types.port;
              default = 6666;
              description = "The port to listen on.";
            };

            dir = lib.mkOption {
              type = lib.types.str;
              default = "/var/lib/kvrocks";
              description = "The working directory.";
            };
          };
        };
        default = { };
        description = ''
          Configuration for kvrocks.
          See <https://github.com/apache/kvrocks/blob/unstable/kvrocks.conf> for supported options.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the firewall for the kvrocks port.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.mkIf cfg.openFirewall [ cfg.settings.port ];

    systemd.services.kvrocks = {
      description = "Kvrocks - A distributed key value NoSQL database that uses RocksDB as storage engine";
      documentation = [ "https://kvrocks.apache.org/" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];

      serviceConfig = {
        Type = "notify";
        ExecStart = "${lib.getExe cfg.package} -c ${configFile}";
        Restart = "on-failure";
        RestartSec = "10s";
        User = "kvrocks";
        Group = "kvrocks";
        StateDirectory = "kvrocks";
        RuntimeDirectory = "kvrocks";
        LimitNOFILE = 100000;
        LimitNPROC = 4096;
        TimeoutSec = 300;
        NoNewPrivileges = true;
      };
    };

    users.users.kvrocks = {
      isSystemUser = true;
      group = "kvrocks";
      description = "Kvrocks daemon user";
    };

    users.groups.kvrocks = { };
  };
}
