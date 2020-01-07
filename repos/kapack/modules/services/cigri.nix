{ config, lib, pkgs, ... }:


with lib;

let
  cfg = config.services.cigri;
inherit (import ./cigri-conf.nix { pkgs=pkgs; lib=lib; cfg=cfg;} ) cigriBaseConf;
in

{

  ###### interface
  
  meta.maintainers = [ maintainers.augu5te ];

  options = {
    services.cigri = {

      package = mkOption {
        type = types.package;
        default = pkgs.nur.repos.kapack.cigri;
        defaultText = "pkgs.nur.repos.kapack.cigri";
      };

      database = {
        host = mkOption {
          type = types.str;
          default = "localhost";
          description = ''
            Host of the postgresql server. 
          '';
        };

        passwordFile = mkOption {
        type = types.nullOr types.path;
        default = null;
        example = "/run/keys/cigri-dbpassword";
        description = ''
          A file containing the usernames/passwords for database, content example:

          DATABASE_USER_NAME="cigri"
          DATABASE_USER_PASSWORD="cigri"
        '';
        };
        
        dbname = mkOption {
          type = types.str;
          default = "cigri";
          description = "Name of the postgresql database";
        };
      };

      extraConfig = mkOption {
        type = types.attrs;
        default = {};
        example = {
          LOG_LEVEL="3";
          DEFAULT_JOB_RESOURCES="/resource_id=1";
        };
        description = ''
          Extra configuration options that will replace default.
        '';
      };

      client = {
        enable = mkEnableOption "CiGri client";
      };

      server = {
        enable = mkEnableOption "CiGri server";
        host = mkOption {
          type = types.str;
          default = "localhost";
          description = ''
            Host of the CiGri server. 
          '';
        };
        logfile = mkOption {
          type = types.str;
          default = "/dev/null";
          description = "Specify the log file name.";
          example = "/var/cigri/state/home/cigri.log";
        };

        statePath = mkOption {
          type = types.str;
          default = "/var/cigri/state";
          description = ''
          Cigri state directory. Configuration, repositories and
          logs, among other things, are stored here.

          The directory will be created automatically if it doesn't
          exist already.
        '';
      };


        
      };
      
      dbserver = {
        enable = mkEnableOption "CiGri database";
      };
    };

    

    
  };

  ###### implementation

  config = mkIf ( cfg.client.enable ||
                  cfg.server.enable ||
                  cfg.dbserver.enable ) {

    environment.etc."cigri/cigri-base.conf" = { mode = "0600"; source = cigriBaseConf; };
    
    # cigri user declaration
    users.users.cigri = mkIf cfg.server.enable {
      description = "CiGri user";
      home = "${cfg.server.statePath}/home";
      shell = pkgs.bashInteractive;
      uid = 746;
    };
    
    users.groups = [
      { name = "cigri";
        gid = 746;
      }
    ];

    systemd.tmpfiles.rules = mkIf cfg.server.enable [
      "d ${cfg.server.statePath}/home 0750 cigri cigri -"
    ];
    
    systemd.services.cigri-conf-init = {
      wantedBy = [ "network.target" ];
      before = [ "network.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        mkdir -p /etc/cigri

        touch /etc/cigri/cigri.conf
        chmod 600 /etc/cigri/cigri.conf
        chown cigri /etc/cigri/cigri.conf

        cat ${cfg.database.passwordFile} >> /etc/cigri/cigri.conf
        cat /etc/cigri/cigri-base.conf >> /etc/cigri/cigri.conf
      '';
    };
    
    ################
    # Server Section
    systemd.services.cigri-server =  mkIf cfg.server.enable {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target"];
      description = "CiGri server's main process";
      restartIfChanged = false;
      serviceConfig = {
        User = "cigri";
        ExecStart = "${cfg.package}/share/cigri/modules/almighty.rb";
        KillMode = "process";
        Restart = "on-failure";
      };
    };

    ##################
    # Database section 
    
    services.postgresql = mkIf cfg.dbserver.enable {
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

    #networking.firewall.allowedTCPPorts = mkIf cfg.dbserver.enable [5432];
        
    systemd.services.cigridb-init = mkIf cfg.dbserver.enable {
      requires = [ "postgresql.service" ];
      after = [ "postgresql.service" ];
      description = "CiGri DB initialization";
      path = [ config.services.postgresql.package pkgs.sudo];
      wantedBy = [ "multi-user.target" ];
      serviceConfig.Type = "oneshot";
      script = ''
        source ${cfg.database.passwordFile};
        ${cfg.package}/database/init_db.rb \
          -d ${cfg.database.dbname} -u $DATABASE_USER_NAME -p $DATABASE_USER_PASSWORD \
          -t psql -s ${cfg.package}/database/psql_structure.sql
      '';
    };
  };
}
