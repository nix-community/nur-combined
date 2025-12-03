{
  config,
  lib,
  pkgs,
  ...
}:

# networking.firewall.extraCommands = ''
#   iptables -t filter -I nixos-fw -i ve-awesome-service-name -p tcp -m tcp --dport 5432 -j nixos-fw-accept
# '';
# networking.firewall.extraStopCommands = ''
#   iptables -t filter -D nixos-fw -i ve-awesome-service-name -p tcp -m tcp --dport 5432 -j nixos-fw-accept || true
# '';
let
  inherit (lib) flip types mkOption;
  cfg = config.vacu;
  databases = lib.attrValues cfg.databases;
  mapLines = lib.concatMapStringsSep "\n";
  authText = flip mapLines databases (
    d:
    if d.authByIp != null then
      # host  database  user  address     auth-method  [auth-options]
      ''host "${d.name}" "${d.user}" ${d.authByIp}/32 trust''
    else
      # local   database  user  auth-method [auth-options]
      ''local "${d.name}" "${d.user}" peer''
  );
  firewallDatabases = lib.filter (d: d.fromContainer != null) databases;
  firewallCommands = flip mapLines firewallDatabases (
    d:
    "iptables -t filter -I nixos-fw -i ve-${d.fromContainer} -p tcp -m tcp --dport 5432 -j nixos-fw-accept"
  );
  firewallStopCommands = flip mapLines firewallDatabases (
    d:
    "iptables -t filter -D nixos-fw -i ve-${d.fromContainer} -p tcp -m tcp --dport 5432 -j nixos-fw-accept || true"
  );
in
{
  options.vacu.databases = mkOption {
    default = { };
    description = "Databases that should be created and how they should be accessed";
    type = types.attrsOf (
      types.submodule (
        let
          outer_config = config;
        in
        { name, config, ... }:
        {
          options = {
            name = mkOption {
              type = types.str;
              default = name;
              description = "name of the database to create";
            };
            user = mkOption {
              type = types.str;
              default = name;
              description = "username of the user created to access/own the database";
            };
            authByIp = mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "If set, user is authenticated based on connecting from the given ip address";
            };
            authByUser = mkOption {
              type = types.bool;
              default = false;
              description = "If true, user is authenticated based on connecting to the unix socket from a process running as the user";
            };
            fromContainer = mkOption {
              type = types.nullOr types.str;
              default = null;
            };
          };
          config = lib.mkIf (config.fromContainer != null) {
            authByIp = outer_config.containers.${config.fromContainer}.localAddress;
          };
        }
      )
    );
  };

  config = {
    vacu.assertions = map (d: {
      assertion = (isNull d.authByIp) == d.authByUser;
      # assertion = lib.debug.traceVal ((lib.debug.traceVal (isNull d.authByIp)) != (lib.debug.traceVal d.authByUser));
      message = "either set authByIp non-null or authByUser true, but not both for database ${d.name}.";
    }) databases;
    networking.firewall.extraCommands = firewallCommands;
    networking.firewall.extraStopCommands = firewallStopCommands;
    services.postgresql = rec {
      enable = true;
      package = pkgs.postgresql_17_jit;
      dataDir = "/var/postgres/data/${package.psqlSchema}";
      enableJIT = true;
      initdbArgs = [ "--waldir=/var/postgres/wal/${package.psqlSchema}" ];
      ensureUsers = [
        {
          name = "root";
          ensureDBOwnership = true;
          ensureClauses.superuser = true;
        }
      ]
      ++ map (d: { name = d.user; }) databases;
      ensureDatabases = [ "root" ] ++ map (d: d.name) databases;
      settings.listen_addresses = lib.mkForce "0.0.0.0";
      identMap = ''
        login-as postgres postgres 
        login-as root postgres
        login-as root root
        login-as postgres gallerygrab
        login-as root gallerygrab
        login-as shelvacu gallerygrab
      '';
      authentication = lib.mkForce ''
        local all postgres peer
        ${authText}
        local all all peer map=login-as
      '';
    };

    systemd.services.postgresql.postStart = ''

      #START stuff from database.nix
    ''
    + (mapLines (d: ''$PSQL -tAc 'ALTER DATABASE "${d.name}" OWNER TO "${d.user}";' '') databases)
    + ''

      #END stuff from database.nix
    '';
    systemd.services.postgresql.serviceConfig.ReadWritePaths = "/var/postgres";
  };
}
