{ config, lib, pkgs, ... }:
with lib;

let
  cfg = config.services.ear;
  pgSuperUser = config.services.postgresql.superUser;
  useMysql = cfg.database.type == "mysql";
  usePostgresql = cfg.database.type == "postgres";
  inherit (import ./ear-conf.nix { pkgs=pkgs; lib=lib; cfg=cfg;} ) earBaseConf;
in
{
###### interface
  
  meta.maintainers = [];

  options = {
    services.ear = {
      
      package = mkOption {
        type = types.package;
        default = pkgs.nur.repos.kapack.ear;
        defaultText = "pkgs.nur.repos.kapack.ear";
      };
      
      database = {
        enable = mkEnableOption "EAR Database";
        
        type = mkOption {
          type = types.enum [ "mysql" "postgres" ];
          example = "mysql";
          default = "mysql";
          description = "Database engine to use.";
        };
                
        host = mkOption {
          type = types.str;
          default = "eardb";
          description = ''
            Host of the postgresql server. 
          '';
        };

        passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/run/keys/ear-dbpassword";
        description = ''
          A file containing the usernames/passwords for database, content example:
          DBUser=ear_daemon
          DBPassw=password
          # User and password for usermode querys.
          DBCommandsUser=ear_commands
          DBCommandsPassw=password
        '';
        };
        
        dbname = mkOption {
          type = types.str;
          default = "ear";
          description = "Name of the postgresql database";
        };
      };
      
      eargmHost = mkOption {
        type = types.str;
          default = "eargm";
          description = "EAR Global Manager host";
        };

      energyPlugin = mkOption {
          type = types.str;
          default = "energy_rapl.so";
          description = "Energy plugin";
      };
      
      energyModel = mkOption {
          type = types.str;
          default = "avx512_model.so";
          description = "Energy model";
      };
      
      powercapPlugin = mkOption {
          type = types.str;
          default = "inm.so";
          description = "Powercap plugin";
      };
      
      extraConfig = mkOption {
        type = types.attrs;
        default = {};
        example = {
          EARGMEnergyLimit = 550000;
        };
        description = ''
          Extra configuration options that will replace default.
        '';
      };
      daemon = {
        enable = mkEnableOption "EAR Daemon (EARD)";
      };

      global_manager = {
        enable = mkEnableOption "EAR Global Manager (EARGM)";
      };
      
      db_manager = {
        enable = mkEnableOption "EAR Database Manager (EARDBD)";
      };
    };
  };
  ###### implementation!!
  config =  mkIf ( cfg.daemon.enable ||
                   cfg.global_manager.enable ||
                   cfg.db_manager.enable ||
                   cfg.database.enable) {
    
    environment.etc =  mkMerge [
      { "ear/ear-base.conf" = { mode = "0600"; source = earBaseConf; };}
      
      (mkIf cfg.database.enable {
        "ear/ear-db.sql" = { mode = "0666"; source = ./ear-db.sql; };
      })
    ];
    
    environment.systemPackages =  [ pkgs.nur.repos.kapack.ear ];
    environment.variables.EAR_ETC = "/etc";
    environment.variables.EAR_TMP = "/var/lib/ear";
    
      
    security.wrappers = { }; #TODO
    
    systemd.services.ear-conf-init = {
      wantedBy = [ "network.target" ];
      before = [ "network.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        touch /etc/ear/ear.conf

        cat ${cfg.database.passwordFile} >> /etc/ear/ear.conf
        cat /etc/ear/ear-base.conf >> /etc/ear/ear.conf
      '';
    };

    ##########################
    # Database Manager section

    ##########################
    # Database w/ Mysql section

    services.mysql =  optionalAttrs (useMysql && cfg.database.enable) {
      enable = mkDefault true;
      package = mkDefault pkgs.mariadb;
    };


    # TODO: use edb_create to db_create and index setting (note: as we use maria.db user creation must use:
    # CREATE USER '$DBCommandsUser'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD("$DBCommandsPassw");
    # need to patac edb_create.c
    systemd.services.eardb-mysql-init = optionalAttrs (useMysql && cfg.database.enable) {
      requires = [ "mysql.service" ];
      after = [ "mysql.service" ];
      description = "EAR DB Manager initialization";
      path = [ pkgs.mariadb config.services.mysql.package ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      
      script = ''
        source ${cfg.database.passwordFile}
        mkdir -p /var/lib/ear
        if [ ! -f /var/lib/ear/db-created ]; then
            echo "Create EAR DB"
            mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${cfg.database.dbname}"
            echo "Create EAR DB tables"

            mysql -u root -D ${cfg.database.dbname} < /etc/ear/ear-db.sql
            echo "Set DB's users, their grant an misc"

            mysql -u root -D ${cfg.database.dbname} <<EOF
        CREATE USER '$DBUser'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD("$DBPassw");
        GRANT SELECT, INSERT ON ${cfg.database.dbname}.* TO '$DBUser'@'%';
        CREATE USER '$DBCommandsUser'@'%' IDENTIFIED VIA mysql_native_password USING PASSWORD("$DBCommandsPassw");
        GRANT SELECT ON ${cfg.database.dbname}.* TO '$DBCommandsUser'@'%';
        ALTER USER '$DBCommandsUser'@'%' WITH MAX_USER_CONNECTIONS 20;
        FLUSH PRIVILEGES;
        EOF
            touch /var/lib/ear/db-created
        fi
      '';
    };

    # CREATE USER '$DBUser'@'localhost' IDENTIFIED VIA mysql_native_password USING PASSWORD("$DBPassw");
    # GRANT SELECT, INSERT ON ${cfg.database.dbname}.* TO '$DBUser'@'localhost';

    #
    
    #         GRANT SELECT, INSERT ON ${cfg.database.dbname}.* TO '$DBUser'@'localhost';
    # ALTER USER root@localhost IDENTIFIED VIA mysql_native_password USING PASSWORD("verysecret");
    # CREATE USER '$DBUser'@'%' IDENTIFIED BY '$DBPassw';
    
    ##########################
    # Database w/ Postgresql section
    
    #environment.etc = optionalAttrs (usePostgresql && cfg.database.enable) {
    #  "ear/ear-db.sql" = { mode = "0666"; source = ./ear-db.sql; };
    #};
    
    services.postgresql = optionalAttrs (usePostgresql && cfg.database.enable) {
      #TODO TOCOMPLETE (UNSAFE)
      enable = true;
      enableTCPIP = true;
      authentication = mkForce
      ''
        # Generated file; do not edit!
        local all all              ident
        host  all all 0.0.0.0/0 md5
        host  all all ::0.0.0.0/96  md5
      '';
    };

    systemd.services.eardb-pg-init = optionalAttrs (usePostgresql && cfg.database.enable) {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      description = "EAR DB Manager initialization";
      path = [ config.services.postgresql.package ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      
      script = ''
        source ${cfg.database.passwordFile}
        mkdir -p /var/lib/ear
        if [ ! -f /var/lib/ear/db-created ]; then
          echo "Create EAR DB role $DBUser"
          echo ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} psql postgres -c "create role $DBUser with login password '$DBPassw'"
          ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} psql postgres -c "create role $DBUser with login password '$DBPassw'"
          echo "Create EAR DB"
          ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} psql postgres -c "create database ${cfg.database.dbname} with owner $DBUser"

          echo "Create EAR DBCommandsUser role"
          ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} psql postgres -c "create role $DBCommandsUser with login password '$DBCommandsPassw'"

          echo "Create EAR DB tables"
          PGPASSWORD=$DBPassw ${pkgs.postgresql}/bin/psql -U $DBUser \
            -f /etc/ear/ear-db.sql \
            -h localhost ${cfg.database.dbname}

          PGPASSWORD=$DBPassw ${pkgs.postgresql}/bin/psql -U $DBUser \
            -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO $DBCommandsUser" \
            -h localhost ${cfg.database.dbname}
            
            touch /var/lib/ear/db-created
        fi
        '';
    };

    systemd.services.eardbd =  mkIf (cfg.db_manager.enable) {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target"];
      description = "EARDBD - Energy Aware Runtime database cache daemon";
      restartIfChanged = false;
      environment.EAR_ETC = "/etc";
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/eardbd";
        KillMode = "process";
        Restart = "on-failure";
      };
       preStart = ''
         # Backwards compatibility
         if [ ! -d /var/lib/ear ]; then
           mkdir -p /var/lib/ear
           chmod ugo +rwx  /var/lib/ear
        fi
       '';
    };  

    ##################
    # Global Manager section
    
    systemd.services.eargmd = mkIf (cfg.global_manager.enable) {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target"];
      description ="EARGMD - EAR Global Manager";
      environment.EAR_ETC = "/etc";
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/eargmd";
        KillMode = "process";
        Restart = "on-failure";
      };
      preStart = ''
        # Backwards compatibility
        if [ ! -d /var/lib/ear ]; then
          mkdir -p /var/lib/ear
          chmod ugo +rwx  /var/lib/ear
        fi
       '';
    }; 

    ##################
    # Daemon section
    boot.kernelModules = mkIf (cfg.daemon.enable) [ "msr" "cpufreq_userspace" ];
    systemd.services.eard = mkIf (cfg.daemon.enable) {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target"];
      description ="EARD - Energy Aware Runtime Daemon";
      environment.EAR_ETC = "/etc";
      path = [ pkgs.kmod ]; 
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/eard 1";
        KillMode = "process";
        Restart = "on-failure";
      };
      preStart = ''
        if [ -f /sys/devices/system/cpu/intel_pstate/status ]; then
          # needed to switch to intel_cpufreq
          echo passive > /sys/devices/system/cpu/intel_pstate/status
        fi
        # Backwards compatibility
        if [ ! -d /var/lib/ear ]; then
          mkdir -p /var/lib/ear
          chmod ugo +rwx  /var/lib/ear
        fi
       '';
    }; 
  };
}
