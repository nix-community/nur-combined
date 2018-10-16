{ config, lib, pkgs, ... }:

with lib;

let

  cfg = config.services.wekan;

  toEnvVars = envAttrSet:
    "\n" + lib.concatStringsSep "\n" (
      lib.mapAttrsToList (name: val: ''export ${name}="${val}"'') envAttrSet
    ) + "\n";

  mailConfig = {
    options = {
      username = mkOption {
        type = types.string;
        description = "SMTP username";
      };

      password = mkOption {
        type = types.string;
        description = "SMTP password";
      };

      passwordFile = mkOption {
        type = types.string;
        default = pkgs.writeText "wekan-smtp-password" cfg.mail.password;
        description = "SMTP password";
      };

      host = mkOption {
        type = types.string;
        description = "SMTP host";
      };

      port = mkOption {
        type = types.int;
        default = 587;
        description = "SMTP port";
      };
      
      from = mkOption {
        type = types.string;
        default = "wekan@localhost";
        description = "From-Address in Emails.";
      };
    };
  };

in

{

  ###### interface

  options = {

    services.wekan = {

      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to enable wekan, an open-source kanban-style board.";
      };

      port = mkOption {
        type = types.int;
        default = 3000;
        description = "Port to listen on.";
      };

      host = mkOption {
        type = types.string;
        default = "127.0.0.1";
        description = "IP to listen on.";
      };

      user = mkOption {
        type = types.string;
        default = "wekan";
        description = "The user under which wekan runs.";
      };

      group = mkOption {
        type = types.string;
        default = "wekan";
        description = "The group under which wekan runs.";
      };

      rootUrl = mkOption {
        type = types.string;
        default = "http://localhost:3000/";
        description = "Public URL pointing to wekan instance.";
      };

      mongoUrl = mkOption {
        type = types.string;
        default = "mongodb://localhost:27017/wekan";
        description = "MongoDB url.";
      }; 

      enableApi = mkOption {
        type = types.bool;
        default = true;
        description = "Whether to enable the wekan API. This is required for exporting boards.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.wekan;
        description = "wekan package to use.";
      };

      nodePackage = mkOption {
        type = types.package;
        default = pkgs.nodejs-8_x;
        description = "Node.js package to use.";
      };

      mail = mkOption {
        type = with types; nullOr (submodule mailConfig);
        default = null;
        description = "wekan mail config";
      };

    };
  };


  ###### implementation

  config = mkIf cfg.enable {

    users.extraUsers."${cfg.user}".extraGroups = [ cfg.group ];
    users.extraGroups."${cfg.group}" = {};


    systemd.services.wekan = {
      enable = true;
      description = "wekan kanban";

      after = [ "network.target" "mongodb.service" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig =
        let
          startScript = pkgs.writeScript "wekan-start" (
            "#! ${pkgs.bash}/bin/bash" +
            (toEnvVars {
              PORT = builtins.toString cfg.port;
              BIND_IP = cfg.host;

              ROOT_URL = cfg.rootUrl;
              MONGO_URL = cfg.mongoUrl;

              WITH_API = lib.boolToString cfg.enableApi;

              MATOMO_ADDRESS = "";
              MATOMO_SITE_ID = "";
              MATOMO_DO_NOT_TRACK = lib.boolToString true;
              MATOMO_WITH_USERNAME = lib.boolToString false;

              BROWSER_POLICY_ENABLED = lib.boolToString true;
              TRUSTED_URL = "";

              WEBHOOKS_ATTRIBUTES = "";

              OAUTH2_CLIENT_ID = "";
              OAUTH2_SECRET = "";
              OAUTH2_SERVER_URL = "";
              OAUTH2_AUTH_ENDPOINT = "";
              OAUTH2_USERINFO_ENDPOINT = "";
              OAUTH2_TOKEN_ENDPOINT = "";
            }) +
            (if !(isNull cfg.mail) then toEnvVars {
              MAIL_PASSWORD = ''$( cat "${cfg.mail.passwordFile}" )'';
              MAIL_URL = "smtp://${ cfg.mail.username }:$MAIL_PASSWORD@${ cfg.mail.host }:${ builtins.toString cfg.mail.port }";
              MAIL_FROM = cfg.mail.from;
            } else "") +
            ''${pkgs.su}/bin/su -m -s "${pkgs.bash}/bin/bash" -c "exec ${cfg.nodePackage}/bin/node ${cfg.package}/main.js" "${cfg.user}"''
          );

        in {
          ExecStart = startScript;
          Type = "simple";

          StandardOutput="syslog";
          StandardError="syslog";
          SyslogIdentifier="wekan";
        };
    };

  };

}
