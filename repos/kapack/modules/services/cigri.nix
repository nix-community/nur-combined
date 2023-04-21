{ config, lib, pkgs, ... }:


with lib;

let
  cfg = config.services.cigri;
inherit (import ./cigri-conf.nix { pkgs=pkgs; lib=lib; cfg=cfg;} ) cigriBaseConf cigriApiClientsConf unicornConfig;

cigriEnv = {
  HOME = "${cfg.server.statePath}/home";
  UNICORN_PATH = "${cfg.server.statePath}/";
  CIGRI_API_PATH = "${cfg.package}/share/cigri/api";
  #CIGRI_LOG_PATH = "${cfg.server.statePath}/log";
};

apacheHttpdWithIdent = pkgs.apacheHttpd.overrideAttrs (oldAttrs: rec {
  configureFlags = oldAttrs.configureFlags ++ [ "--enable-ident" ]; });

in

{

  ###### interface
  
  meta.maintainers = [];

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

        api_port = mkOption {
          type = types.int;
          default = 80;
          description = ''
            Port to access to Cigir's Rest API.
          '';
        };

        api_base = mkOption {
          type = types.str;
          default = "/cigri-api";
          
          description = ''
            Base location to Cigir's Rest API.
          '';
        };
        
        api_SSL = mkEnableOption "Enable API_SSL"; # TODO to finish

        web = {
          enable = mkEnableOption "Web server to serve rest-api";
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
    environment.etc."cigri/api-clients.conf" = mkIf cfg.client.enable {source = cigriApiClientsConf; };

    environment.systemPackages =  [ pkgs.nur.repos.kapack.cigri ];
    # cigri user declaration
    users.users.cigri = mkIf cfg.server.enable {
      description = "CiGri user";
      home = "${cfg.server.statePath}/home";
      shell = pkgs.bashInteractive;
      group = "cigri";
      uid = 746;
    };
    
    users.groups.cigri.gid = mkIf cfg.server.enable 746;

    systemd.tmpfiles.rules = mkIf cfg.server.enable [
      "d ${cfg.server.statePath}/home 0750 cigri cigri -"
      "d ${cfg.server.statePath}/config 0750 cigri cigri -"
      "d ${cfg.server.statePath}/log 0750 cigri cigri -"
      "d ${cfg.server.statePath}/tmp 0750 cigri cigri -"
      "d ${cfg.server.statePath}/tmp/pids 0750 cigri cigri -"
      "d ${cfg.server.statePath}/tmp/sockets 0750 cigri cigri -"
    ];
    
    systemd.services.cigri-conf-init = mkIf cfg.server.enable {
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

        echo '{"normal_authorized": {}}' > /etc/cigri/user_lists

      '';
    };
    
    ################
    # Server Section
    systemd.services.cigri-server =  mkIf cfg.server.enable {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target"];
      description = "CiGri's server main process";
      restartIfChanged = false;
      serviceConfig = {
        User = "cigri";
        ExecStart = "${cfg.package}/share/cigri/modules/almighty.rb";
        KillMode = "process";
        Restart = "on-failure";
      };
    };

    ################
    # Rest-api Section
    systemd.services.cigri-rest-api =  mkIf cfg.server.enable {
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "CiGri's rest api";
      environment = cigriEnv;
      serviceConfig = {
        Type = "simple";
        User = "cigri";
        TimeoutSec = "infinity";
        KillMode = "process";
        Restart = "on-failure";
        WorkingDirectory = "${cfg.package}/share/cigri/api";
        ExecStart = "${cfg.package.rubyEnv}/bin/unicorn -d -c ${unicornConfig} -E production";
      };
    };
    
    services.httpd =  mkIf cfg.server.web.enable {
      user="cigri";
      group="cigri";
      package = apacheHttpdWithIdent;
      enable = true;
      adminAddr = "foo@example.org";
      extraModules = [ "ident"];
      extraConfig = ''
        <Location ${cfg.server.api_base}>
        
          # Deny access by default, except from localhost

          Order deny,allow
          Allow from             ${cfg.server.host}
          Deny from all
          # Pidentd is a simple and efficient way to authentify unix users on a cigri frontend
          <IfModule ident_module>
            IdentityCheck On
            # We need the rewrite module to set the X_CIGRI_USER header variable from the 
            # ident_module output.
            RewriteEngine On
            RewriteCond %{REMOTE_IDENT} (.*)
            RewriteRule .* - [E=HTTP_X_CIGRI_USER:%1]
            RequestHeader set X-Cigri-User "%{HTTP_X_CIGRI_USER}e"
          </IfModule>

          ProxyPass unix://${cfg.server.statePath}/tmp/sockets/cigri.socket|http://${cfg.server.host}/
          ProxyPassReverse unix://${cfg.server.statePath}/tmp/sockets/cigri.socket|http://${cfg.server.host}/
        </Location>
      '';
    };

    services.oidentd.enable = mkIf cfg.server.web.enable true;
      
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
