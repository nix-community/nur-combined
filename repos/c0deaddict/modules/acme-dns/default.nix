{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.acme-dns;

  format = pkgs.formats.toml { };

  configFile = format.generate "acme-dns.cfg" cfg.settings;

  domainConfig = types.submodule {
    options = {
      username = mkOption {
        type = types.str;
        description = "Username UUID";
      };

      subdomain = mkOption {
        type = types.str;
        description = "Subdomain UUID";
      };

      passwordHash = mkOption {
        type = types.str;
        description = ''
          Bcrypt password hash. Create with: mkpasswd -m bcrypt -R10
        '';
      };

      allowFrom = mkOption {
        type = types.listOf types.str;
        default = [ "127.0.0.1/8" ];
      };
    };
  };

  data = pkgs.writeText "acme-dns-data.sql" (concatStringsSep "\n" (lib.mapAttrsToList
    (name: entry: ''
      INSERT INTO records (Username, Password, Subdomain, AllowFrom)
          VALUES ('${entry.username}', '${entry.passwordHash}', '${entry.subdomain}',
              '${builtins.toJSON(entry.allowFrom)}');
      INSERT INTO txt (Subdomain, Value, LastUpdate)
          VALUES ('${entry.subdomain}', 'bogus', 0);
    '')
    cfg.domains));

  provision = pkgs.writers.writeDash "provision-database" ''
    db="/var/lib/acme-dns/acme-dns.db"
    rm -fr "$db"
    ${pkgs.sqlite}/bin/sqlite3 --init /dev/null $db ".read ${./schema.sql}"
    ${pkgs.sqlite}/bin/sqlite3 --init /dev/null $db ".read ${data}"
  '';

in
{

  ### Interface

  options = {
    services.acme-dns = {
      enable = mkEnableOption (lib.mdDoc "ACME DNS server");

      package = mkOption {
        type = types.package;
        default = pkgs.acme-dns;
      };

      settings = mkOption {
        default = { };
        type = format.type;
      };

      domains = mkOption {
        type = types.attrsOf domainConfig;
        description = "Provision acme-dns database with domains";
      };
    };
  };

  ### Implementation

  config = mkIf cfg.enable {
    systemd.services.acme-dns = {
      description = "ACME DNS server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      serviceConfig = {
        Type = "simple";

        ExecStart = "${cfg.package}/bin/acme-dns -c ${configFile}";
        ExecStartPre = [ provision ];
        Restart = "on-failure";

        DynamicUser = true;
        StateDirectory = "acme-dns";
        StateDirectoryMode = "0750";

        # Hardening
        AmbientCapabilities = [ "CAP_NET_BIND_SERVICE" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        # NOTE: acme-dns fails to bind port with this enabled.
        # PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        #  need bind from privileged, nothing else?
        # SystemCallFilter = [ "@system-service" "~@privileged" ];
        UMask = "0077";
      };
    };
  };

}
