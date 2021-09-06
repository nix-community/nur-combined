{ config, pkgs, lib, ... }: with lib; let
  cfg = config.services.glauth;
  dbcfg = config.services.glauth.database;
in
{
  options.services.glauth = {
    enable = mkEnableOption "GLAuth";
    package = mkOption {
      type = types.package;
      default = pkgs.glauth;
    };
    configFile = mkOption {
      description = "The config path that GLAuth uses";
      type = types.path;
      default = pkgs.writeText "glauth-config" (toTOML cfg.settings);
    };
    database = {
      enable = mkEnableOption "use a database";
      local = mkEnableOption "local database creation" // { default = true; };
      type = mkOption {
        type = types.enum [
          "postgres"
          "mysql"
          "sqlite"
        ];
        default = "sqlite";
      };
      host = mkOption {
        type = types.str;
        default = "localhost";
      };
      port = mkOption {
        type = with types; nullOr port;
        default = attrByPath [ dbcfg.type ] null {
          "postgres" = 5432;
          "mysql" = 3306;
        };
      };
      username = mkOption {
        type = types.str;
        default = "glauth";
      };
      passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
      };
      ssl = mkEnableOption "use ssl for the database connection";
    };
    settings = mkOption {
      type = json.types.attrs;
      default = {};
    };
  };
  config = let
    localCheck = dbcfg.local && dbcfg.enable && dbcfg.host == "localhost";
    postgresCheck = localCheck && dbcfg.type == "postgres";
    mysqlCheck = localCheck && dbcfg.type == "mysql";
  in mkIf cfg.enable {
    services.glauth.settings = mkIf cfg.database.enable {
      backend =
        let
          pluginHandlers = {
            "mysql" = "NewMySQLHandler";
            "postgres" = "NewPostgresHandler";
            "sqlite" = "NewSQLiteHandler";
          };
        in
        {
          datastore = "plugin";
          plugin = "${cfg.package}/bin/${dbcfg.type}.so";
          pluginhandler = pluginHandlers.${dbcfg.type};
          database = if (dbcfg.type != "sqlite") then (builtins.replaceStrings (singleton "\n") (singleton " ") ''
            host=${dbcfg.host}
            port=${toString dbcfg.port}
            dbname=glauth
            user=${dbcfg.username}
            password=@db-password@
            sslmode=${if dbcfg.ssl then "enable" else "disable"}
          '') else "database = \"gl.db\"";
        };
      };


    systemd.services.glauthPostgreSQLInit = lib.mkIf postgresCheck {
      after = [ "postgresql.service" ];
      before = [ "glauth.service" ];
      requires = [ "postgresql.service" ];
      path = [ config.services.postgresql.package ];
      serviceConfig = {
        Type = "oneshot";
        User = "postgres";
        Group = "postgres";
      };
      script = ''
        set -o errexit -o pipefail -o nounset -o errtrace
        shopt -s inherit_errexit
        create_role="$(mktemp)"
        trap 'rm -f "$create_role"' ERR EXIT
        echo "CREATE ROLE glauth WITH LOGIN PASSWORD '$(<'${dbcfg.passwordFile}')' CREATEDB" > "$create_role"
        psql -tAc "SELECT 1 FROM pg_roles WHERE rolname='glauth'" | grep -q 1 || psql -tA --file="$create_role"
        psql -tAc "SELECT 1 FROM pg_database WHERE datname = 'glauth'" | grep -q 1 || psql -tAc 'CREATE DATABASE "glauth" OWNER "glauth"'
      '';
    };

    systemd.services.glauthMySQLInit = lib.mkIf mysqlCheck {
      after = [ "mysql.service" ];
      before = [ "glauth.service" ];
      requires = [ "mysql.service" ];
      path = [ config.services.mysql.package ];
      serviceConfig = {
        Type = "oneshot";
        User = config.services.mysql.user;
        Group = config.services.mysql.group;
      };
      script = ''
        set -o errexit -o pipefail -o nounset -o errtrace
        shopt -s inherit_errexit
        db_password="$(<'${dbcfg.passwordFile}')"
        ( echo "CREATE USER IF NOT EXISTS 'glauth'@'localhost' IDENTIFIED BY '$db_password';"
          echo "CREATE DATABASE glauth CHARACTER SET utf8 COLLATE utf8_unicode_ci;"
          echo "GRANT ALL PRIVILEGES ON glauth.* TO 'glauth'@'localhost';"
        ) | mysql -N
      '';
    };

    users.groups.glauth = { };
    users.users.glauth = {
      isSystemUser = true;
      extraGroups = singleton "glauth";
    };

    systemd.services.glauth =
      let
        passworded = dbcfg.passwordFile != null;
        databaseServices = attrByPath [ dbcfg.type ] [ ] {
          "mysql" = singleton "mysql.service" ++ optional dbcfg.local "glauthMySQLInit.service";
          "postgres" = singleton "postgresql.service" ++ optional dbcfg.local "glauthPostgreSQLInit.service";
        };
      in {
        after = databaseServices;
        wantedBy = singleton "multi-user.target";
        path = lib.optional passworded pkgs.replace-secret;
      serviceConfig = {
        ExecStartPre =
          let
            startPreFullPrivileges = ''
              set -o errexit -o pipefail -o nounset -o errtrace
              shopt -s inherit_errexit
              umask u=rwx,g=,o=
              install -T -m 0400 -o glauth -g glauth '${dbcfg.passwordFile}' $RUNTIME_DIRECTORY/db_password
            '';
            startPre = ''
              install -T -m 0600 ${cfg.configFile} $RUNTIME_DIRECTORY/config.cfg
              ${lib.optionalString passworded ''replace-secret '@db-password@' "$RUNTIME_DIRECTORY/db_password" "$RUNTIME_DIRECTORY/config.cfg"''}
            '';
          in
          lib.optional passworded "+${pkgs.writeShellScript "glauth-start-pre-full-privileges" startPreFullPrivileges}"
          ++ singleton "${pkgs.writeShellScript "glauth-start-pre" startPre}";
        ExecStart = "${cfg.package}/bin/glauth -c %t/glauth/config.cfg";
        User = "glauth";
        Group = "glauth";
        RuntimeDirectory = "glauth";
        LogsDirectory = "glauth";
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
      };
    };
  };
}
