{ config, lib, networking, pkgs, ... }:

with lib;

let

  cfg = config.services.writefreely;
  defaultConfig = {
    server = {
      port = 8080;
      bind = "localhost";
      autocert = false;
      templates_parent_dir = "${pkgs.writefreely}/lib";
      static_parent_dir = "${pkgs.writefreely}/lib";
      pages_parent_dir = "${pkgs.writefreely}/lib";
    };
    database = {
      type = "sqlite3";
      filename = "writefreely.db";
    };
    app = {
      site_name = "NixOS Writefreely module";
      site_description = "Default config for the NixOS Writefreely module";
      host = "http://localhost:8080";
      theme = "write";
      disable_js = false;
      webfonts = true;
      simple_nav = false;
      wf_modesty = false;
      chorus = false;
      disable_drafts = false;
      single_user = true;
      open_registration = false;
      min_username_len = 3;
      max_blogs = 1;
      federation = true;
      public_stats = true;
      private = false;
      local_timeline = false;
    };
  };

in

{

  ###### interface

  options = {

    services.writefreely = rec {

      enable = mkOption {
        default = false;
        description = "Whether to enable writefreely.";
      };

      user = mkOption {
        default = "writefreely";
        description = "The user to run writefreely as";
      };

      group = mkOption {
        default = cfg.user;
        description = "The group to run writefreely as (default same as user)";
      };

      config = mkOption {
        default = {  };
        description = ''
          Set options in the writefreely ini file. You must set the following options:
            app.host
            app.site_description
            app.site_name
            server.port
          All other values will use defaults set in the module.
          '';
      };

      configFile = mkOption {
        default = null;
        description = ''
          Path to the writefreely ini file. Overrides the config option.
          You need to provide a fully working configuration file and setup all paths yourself.
          You MUST set templates_parent_dir, static_parent_dir and pages_parent_dir in the [server] section or writefreely will probably fail.
          '';
      };

      dataPath = mkOption {
        default = "/var/lib/writefreely";
        description = ''
          Writefreely working directory. Important if you use relative paths in your config.
          '';
      };

      defaultUserPass = mkOption {
        default = null;
        description = ''
          Add an inital user. Format: USER:PASSWORD
          '';
      };

    };

  };

  ###### implementation

  config = mkIf config.services.writefreely.enable {

    users.extraUsers."${cfg.user}" = {
      group = cfg.group;
      isSystemUser = true;
      description = "writefreely";
    };

    users.extraGroups."${cfg.group}" = {  };

    systemd.services.writefreely =
      let cfgFile = if ! isNull cfg.configFile then cfg.configFile else ( pkgs.writeText "writefreely.ini" ( lib.generators.toINI {} (recursiveUpdate defaultConfig cfg.config) ));
      in
      {
        description = "writefreely server";

        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        path = [ pkgs.openssl ];
        serviceConfig = {
          ExecStartPre = (
            pkgs.writeScript "writefreely-init" ''
              #!${pkgs.stdenv.shell} -e
              echo Init DB:
              ${pkgs.writefreely}/bin/writefreely -c ${cfgFile} --init-db
              echo Generate Keys:
              ${pkgs.writefreely}/bin/writefreely -c ${cfgFile} keys generate
              echo Create default user:
              ${if isNull cfg.defaultUserPass then "" else "${pkgs.writefreely}/bin/writefreely -c ${cfgFile} --create-admin ${cfg.defaultUserPass} || :"}
            '' );
          ExecStart = "${pkgs.writefreely}/bin/writefreely -c ${cfgFile}";
          WorkingDirectory = "/var/lib/writefreely";
          StateDirectory = "writefreely";
          StateDirectoryMode = "0700";
          User = cfg.user;
        };

    };

  };

}
