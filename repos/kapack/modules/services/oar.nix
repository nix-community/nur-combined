{ config, lib, pkgs, ... }:

# TODO Assert on password prescence
# TODO Drawgantt

with lib;

let
  cfg = config.services.oar;
  pgSuperUser = config.services.postgresql.superUser;

  inherit (import ./oar-conf.nix {
    pkgs = pkgs;
    lib = lib;
    cfg = cfg;
  })
    oarBaseConf oarSshdConf monikaBaseConf drawganttBaseConf;

  # Move to independant package ?
  oarVisualization = pkgs.stdenv.mkDerivation {
    name = "oar_visualization";
    buildInputs = [ pkgs.makeWrapper pkgs.perl ];
    phases = [ "installPhase" "fixupPhase" ];

    installPhase = ''
       mkdir -p $out/monika/share

       cp -r ${cfg.package}/visualization_interfaces/Monika/lib $out/monika/
       cp ${cfg.package}/visualization_interfaces/Monika/monika.css $out/monika/
       substitute ${cfg.package}/visualization_interfaces/Monika/monika.cgi.in $out/monika/share/monika.cgi \
         --replace "%%OARCONFDIR%%" /etc/oar

       chmod a+x $out/monika/share/monika.cgi

       makeWrapper $out/monika/share/monika.cgi $out/monika/monika.cgi --set PERL5LIB \
         "${
           with pkgs.perlPackages;
           makePerlPath ([
             CGI
             DBI
             DBDPg
             AppConfig
             SortNaturally
             TieIxHash
             HTMLParser
           ])
         }:$out/monika/lib"

      mkdir -p $out/drawgantt
      substitute ${cfg.package}/visualization_interfaces/DrawGantt-SVG/drawgantt.php.in $out/drawgantt/drawgantt.php \
        --replace "%%OARCONFDIR%%" /etc/oar
      substitute ${cfg.package}/visualization_interfaces/DrawGantt-SVG/drawgantt-svg.php.in $out/drawgantt/drawgantt-svg.php \
        --replace "%%OARCONFDIR%%" /etc/oar
    '';
  };

  oarTools = pkgs.stdenv.mkDerivation {
    name = "oar_tools";
    phases = [ "installPhase" ];
    buildInputs = [ ];
    installPhase = ''
      mkdir -p $out/bin

      #oarsh
      substitute ${cfg.package}/tools/oarsh/oarsh.in $out/bin/oarsh \
        --replace "%%OARHOMEDIR%%" ${cfg.oarHomeDir} \
        --replace "%%XAUTHCMDPATH%%" /run/current-system/sw/bin/xauth \
        --replace /usr/bin/ssh /run/current-system/sw/bin/ssh
      chmod 755 $out/bin/oarsh

      #oarsh_shell
      substitute ${cfg.package}/tools/oarsh/oarsh_shell.in $out/bin/oarsh_shell \
        --replace "/bin/bash" "${pkgs.bash}/bin/bash" \
        --replace "%%XAUTHCMDPATH%%" /run/current-system/sw/bin/xauth \
        --replace "\$OARDIR/oardodo/oardodo" /run/wrappers/bin/oardodo \
        --replace "%%OARCONFDIR%%" /etc/oar \
        --replace "%%OARDIR%%" /run/wrappers/bin \

      chmod 755 $out/bin/oarsh_shell

      #oardodo
      substitute ${cfg.package}/tools/oardodo.c.in oardodo.c\
        --replace "%%OARDIR%%" /run/wrappers/bin \
        --replace "%%OARCONFDIR%%" /etc/oar \
        --replace "%%XAUTHCMDPATH%%" /run/current-system/sw/bin/xauth \
        --replace "%%ROOTUSER%%" root \
        --replace "%%OAROWNER%%" oar

      $CC -Wall -O2 oardodo.c -o $out/oardodo_toWrap

      #oardo -> cli
      gen_oardo () {
        substitute ${cfg.package}/tools/oardo.c.in oardo.c\
          --replace TT/usr/local/oar/oarsub ${pkgs.nur.repos.kapack.oar}/bin/$1 \
          --replace "%%OARDIR%%" /run/wrappers/bin \
          --replace "%%OARCONFDIR%%" /etc/oar \
          --replace "%%XAUTHCMDPATH%%" /run/current-system/sw/bin/xauth \
          --replace "%%OAROWNER%%" oar \
          --replace "%%OARDOPATH%%"  /run/wrappers/bin:/run/current-system/sw/bin

        $CC -Wall -O2 oardo.c -o $out/$2
      }

      # generate cli
      a=(oarsub oarstat oardel oarresume oarnodes oarnotify oarqueue oarconnect oarremoveresource \
      oarnodesetting oaraccounting oarproperty oarwalltime)

      for (( i=0; i<''${#a[@]}; i++ ))
      do
        echo generate ''${a[i]}
        gen_oardo .''${a[i]} ''${a[i]}
      done

    '';
  };

in
{
  ###### interface

  meta.maintainers = [];

  options = {
    services.oar = {

      package = mkOption {
        type = types.package;
        default = pkgs.nur.repos.kapack.oar;
        defaultText = "pkgs.nur.repos.kapack.oar";
      };

      privateKeyFile = mkOption {
        type = types.str;
        default = "/run/keys/oar_id_rsa_key";
        description = "Private key for oar user";
      };

      publicKeyFile = mkOption {
        type = types.str;
        default = "/run/keys/oar_id_rsa_key.pub";
        description = "Public key for oar user";
      };

      oarHomeDir = mkOption {
        type = types.str;
        default = "/var/lib/oar";
        description = "Home for oar user";
      };

      # cpusetBasePath = mkOption {
      #   type = types.str;
      #   default = "/dev/oar_cgroups_links/cpuset";
      #   description = "Cpuset base path for job processes";
      # };

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
          example = "/run/keys/oar-dbpassword";
          description = ''
            A file containing the usernames/passwords for database, content example:

            # DataBase user name
            DB_BASE_LOGIN="oar"

            # DataBase user password
            DB_BASE_PASSWD="oar"

            # DataBase read only user name
            DB_BASE_LOGIN_RO="oar_ro"

            # DataBase read only user password
            DB_BASE_PASSWD_RO="oar_ro"
          '';
        };

        dbname = mkOption {
          type = types.str;
          default = "oar";
          description = "Name of the postgresql database";
        };

        initPath = mkOption {
          type = types.listOf types.package;
          default = [ ];
          description = "List of Package made available for postInitCommands";
        };

        postInitCommands = mkOption {
          default = "";
          example = "touch /etc/foo";
          type = types.lines;
          description = ''
          Shell commands to be executed just after OAR DB initialization.
          '';
        };
      };

      extraConfig = mkOption {
        type = types.attrs;
        default = { };
        example = {
          LOG_LEVEL = "3";
          OARSUB_DEFAULT_RESOURCES = "/resource_id=1";
        };
        description = ''
          Extra configuration options that will replace default.
        '';
      };

      client = { enable = mkEnableOption "OAR client"; };

      node = {
        enable = mkEnableOption "OAR node";
        register = {
          enable = mkEnableOption "Register node into OAR server";
          add = mkOption {
            type = types.bool;
            default = true;
            description = "Execute oarnodesseting";
          };
          extraCommand = mkOption {
            type = types.str;
            default = "";
            description = "Extra command called once after registration";
          };
        };
        # job_notifier = {
        #   enable = mkEnableOption "Job start/end notifier";
        #   command = mkOption {
        #     type = types.str;
        #     default = "";
        #     description = "Command to call (first arg START|END, second job_id)";
        #   };
        # };
      };

      server = {
        enable = mkEnableOption "OAR server";
        host = mkOption {
          type = types.str;
          default = "localhost";
          description = ''
            Host of the OAR server.
          '';
        };
      };

      dbserver = { enable = mkEnableOption "OAR database"; };

      web = {
        enable = mkEnableOption "OAR web server and rest-api";
        monika = {
          enable = mkEnableOption "Monkia resources' status web page";
        };
        drawgantt = { enable = mkEnableOption "Drawgantt web page"; };
        proxy = {
          enable = mkEnableOption "Enable proxy service based on Traefik";
          entryPointHttp = mkOption {
            type = types.str;
            default = "";
            description = ''
              Entry Point for proxy server (example "server:5000").
            '';
          };
          configOptions = mkOption {
            description = ''
              Config for Traefik.
            '';
            type = types.attrs;
            default = {
              defaultentrypoints = [ "http" ];
              #     # [api]
              #     # dashboard = true
              #     # entrypoint = "auth_api"
              wss.protocol = "http";
              file.filename = "/etc/oar/proxy/rules_oar_traefik.toml";
              file.watch = true;
            };
          };
        };
        extraConfig = mkOption {
          type = types.str;
          default = "";
          description = ''
            Extra configuration to append to Nginx's one.
          '';
        };
      };

    };
  };
  ###### implementation

  config = mkIf
    (cfg.client.enable || cfg.node.enable || cfg.server.enable
      || cfg.dbserver.enable)
    {

      environment.etc."oar/oar-base.conf" = {
        mode = "0600";
        source = oarBaseConf;
      };

      # add package*
      # TODO oarVisualization conditional
      environment.systemPackages = [
        oarVisualization
        oarTools
        pkgs.taktuk
        pkgs.xorg.xauth
        pkgs.nur.repos.kapack.oar
      ];

      # manage setuid for oardodo and oarcli
      security.wrappers = {
        oardodo = {
          source = "${oarTools}/oardodo_toWrap";
          owner = "root";
          group = "oar";
          setuid = true;
          permissions = "u+rwx,g+rx";
        };
      } // lib.genAttrs [
        "oarsub"
        "oarstat"
        "oarresume"
        "oardel"
        "oarnodes"
        "oarnotify"
        "oarqueue"
        "oarconnect"
        "oarremoveresource"
        "oarnodesetting"
        "oaraccounting"
        "oarproperty"
        "oarwalltime"
      ]
        (name: {
          source = "${oarTools}/${name}";
          owner = "root";
          group = "oar";
          setuid = true;
          permissions = "u+rx,g+x,o+x";
        });

      # oar user declaration
      users.users.oar =
        mkIf (cfg.client.enable || cfg.node.enable || cfg.server.enable) {
          description = "OAR user";
          isSystemUser = true;
          home = cfg.oarHomeDir;
          shell = "${oarTools}/bin/oarsh_shell";
          group = "oar";
          uid = 745;
        };

      users.groups.oar.gid =
        mkIf (cfg.client.enable || cfg.node.enable || cfg.server.enable) 745;

      systemd.services.oar-user-init = {
        wantedBy = [ "network.target" ];
        before = [ "network.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          # TODO oar/log proper handling
          touch /tmp/oar.log
          chmod 666 /tmp/oar.log

          mkdir -p ${cfg.oarHomeDir}
          chown oar:oar ${cfg.oarHomeDir}

          echo "[ -f ${cfg.oarHomeDir}/.bash_oar ] && . ${cfg.oarHomeDir}/.bash_oar" > ${cfg.oarHomeDir}/.bashrc
          echo "[ -f ${cfg.oarHomeDir}/.bash_oar ] && . ${cfg.oarHomeDir}/.bash_oar" > ${cfg.oarHomeDir}/.bash_profile
          cat <<EOF > ${cfg.oarHomeDir}/.bash_oar
          #
          # OAR bash environnement file for the oar user
          #
          # /!\ This file is automatically created at update installation/upgrade.
          #     Do not modify this file.
          #
          bash_oar() {
            # Prevent to be executed twice or more
            [ -n "$OAR_BASHRC" ] && return
            export PATH="/run/wrappers/bin/:/run/current-system/sw/bin:$PATH"
            OAR_BASHRC=yes
          }

          bash_oar
          EOF

          cd ${cfg.oarHomeDir}
          chown oar:oar .bashrc .bash_profile .bash_oar

          # create and populate .ssh
          mkdir .ssh

          cat <<EOF > .ssh/config
          Host *
          ForwardX11 no
          StrictHostKeyChecking no
          PasswordAuthentication no
          AddressFamily inet
          Compression yes
          Protocol 2
          EOF

          cp ${cfg.privateKeyFile} .ssh/id_rsa
          cp ${cfg.publicKeyFile} .ssh/id_rsa.pub
          echo -n 'environment="OAR_KEY=1" ' > .ssh/authorized_keys
          cat ${cfg.publicKeyFile} >> .ssh/authorized_keys

          chown -R oar:oar .ssh
          chmod 700 .ssh
          chmod 600 .ssh/*
          chmod 644 .ssh/id_rsa.pub
        '';
      };

      # TODO CHANGE environment.etc...
      systemd.services.oar-conf-init = {
        wantedBy = [ "network.target" ];
        before = [ "network.target" ];
        serviceConfig.Type = "oneshot";
        script = ''
          mkdir -p /etc/oar

          # copy some required and useful scripts
          cp ${cfg.package}/tools/*.pl ${cfg.package}/tools/*.sh /etc/oar/

          touch /etc/oar/oar.conf
          chmod 600 /etc/oar/oar.conf
          chown oar /etc/oar/oar.conf

          cat ${cfg.database.passwordFile} >> /etc/oar/oar.conf
          cat /etc/oar/oar-base.conf >> /etc/oar/oar.conf
        '';
      };

      ##############
      # Node Section
      services.openssh = mkIf cfg.node.enable { enable = true; };

      systemd.services.oar-node = mkIf (cfg.node.enable) {
        description = "OAR's SSH Daemon";
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        stopIfChanged = false;
        preStart = ''
          # Make sure we don't write to stdout, since in case of
          # socket activation, it goes to the remote side (#19589).
          exec >&2
          if ! [ -f "/etc/oar/oar_ssh_host_rsa_key" ]; then
            ${pkgs.openssh}/bin/ssh-keygen -t rsa -b 4096 -N "" -f /etc/oar/oar_ssh_host_rsa_key
          fi
        '';
        serviceConfig = {
          ExecStart = "${pkgs.openssh}/bin/sshd -f ${oarSshdConf}";
          KillMode = "process";
          Restart = "always";
          Type = "simple";
        };
      };

      systemd.services.oar-node-register = mkIf (cfg.node.register.enable) {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" "oar-user-init.service" "oar-conf-init.service" "oar-node.service" ];
        serviceConfig.Type = "oneshot";
        path = [ pkgs.hostname ];
        script = concatStringsSep "\n" [
          (optionalString cfg.node.register.add
            "/run/wrappers/bin/oarnodesetting -a -s Alive")
          (optionalString (cfg.node.register.extraCommand != "") ''
            ${cfg.node.register.extraCommand}
          '')
        ];
      };

      ####
      # systemd.services.oar-node-job-notifier = mkIf (cfg.node.job_notifier.enable) {
      #   wantedBy = [ "multi-user.target" ];
      #   after = [ "network.target" "oar-user-init" "oar-conf-init" "oar-node" ];
      #    path = [ pkgs.inotify-tools ];
      #    script = ''
      #       source /etc/oar/oar.conf
      #       cpuset_path=${cfg.cpusetBasePath}$CPUSET_PATH

      #       # TODO prepare_cpuset_nixos.pl|py

      #       ${pkgs.inotify-tools}/bin/inotifywait -q -m -e create -e delete --format '%:e %f' \
      #           $cpuset_path | \
      #       while read events; do
      #       echo $events $CPUSET_PATH >> /tmp/yop
      #       done
      #       # ${cfg.node.job_notifier.command}
      #     '';
      #    serviceConfig = {
      #      User = "oar";
      #      Group = "oar";
      #      KillMode = "process";
      #      Type = "simple";
      #      Restart = "always";
      #    };
      # };

      ################
      # Server Section
      systemd.services.oar-server = mkIf (cfg.server.enable) {
        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];
        description = "OAR server's main processes";
        restartIfChanged = false;
        environment.OARDIR = "${cfg.package}/bin";
        serviceConfig = {
          User = "oar";
          Group = "oar";
          ExecStart = "${cfg.package}/bin/oar-almighty";
          KillMode = "process";
          Restart = "on-failure";
          RestartSec = "1s";
        };
      };

      ##################
      # Database section

      services.postgresql = mkIf cfg.dbserver.enable {
        #TODO TOCOMPLETE (UNSAFE)
        enable = true;
        enableTCPIP = true;
        authentication = mkForce ''
          # Generated file; do not edit!
          local all all              ident
          host  all all 0.0.0.0/0 md5
          host  all all ::0.0.0.0/96  md5
        '';
      };

      #networking.firewall.allowedTCPPorts = mkIf cfg.dbserver.enable [5432];

      systemd.services.oar-db-init = mkIf cfg.dbserver.enable {
        requires = [ "postgresql.service" ];
        after = [ "postgresql.service" ];
        description = "OARD DB initialization";
        path = [ config.services.postgresql.package ] ++ cfg.database.initPath;
        wantedBy = [ "multi-user.target" ];
        serviceConfig.Type = "oneshot";

        script = ''
          source ${cfg.database.passwordFile};
          mkdir -p /var/lib/oar
          if [ ! -f /var/lib/oar/db-created ]; then
            echo "Create OAR DB role"
            ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} psql postgres -c "create role $DB_BASE_LOGIN with login password '$DB_BASE_PASSWD'";
            echo "Create OAR DB (void)"
            ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} psql postgres -c "create database ${cfg.database.dbname} with owner $DB_BASE_LOGIN";
            echo "Create OAR DB role"
            ${pkgs.sudo}/bin/sudo -u ${pgSuperUser} psql postgres -c "create role $DB_BASE_LOGIN_RO with login password '$DB_BASE_PASSWD_RO'";

            echo "Create OAR DB tables"
            PGPASSWORD=$DB_BASE_PASSWD ${pkgs.postgresql}/bin/psql -U $DB_BASE_LOGIN \
              -f ${cfg.package}/setup/database/pg_structure.sql \
              -f ${cfg.package}/setup/database/default_data.sql \
              -h localhost ${cfg.database.dbname}

            PGPASSWORD=$DB_BASE_PASSWD ${pkgs.postgresql}/bin/psql -U $DB_BASE_LOGIN \
              -c "GRANT SELECT ON ALL TABLES IN SCHEMA public TO $DB_BASE_LOGIN_RO;" \
              -h localhost ${cfg.database.dbname}

            ${cfg.database.postInitCommands}

            touch /var/lib/oar/db-created
          fi
        '';
      };

      #################
      # Web Section

      services.nginx = mkIf cfg.web.enable {
        enable = true;
        user = "oar";
        group = "oar";

        virtualHosts.default = {
          #TODO root = "${pkgs.nix.doc}/share/doc/nix/manual";
          extraConfig =
            let fcgi = config.services.fcgiwrap;
            in
            concatStringsSep "\n" [
              ''
                location @oarapi {
                  rewrite ^/oarapi-priv/?(.*)$ /$1 break;
                  rewrite ^/oarapi/?(.*)$ /$1 break;

                  include ${pkgs.nginx}/conf/uwsgi_params;

                  uwsgi_pass unix:/run/uwsgi/oarapi.sock;
                  uwsgi_param HTTP_X_REMOTE_IDENT $remote_user;
                }

                location ~ ^/oarapi-priv {
                  auth_basic "OAR API Authentication";
                  auth_basic_user_file /etc/oar/api-users;
                  error_page 404 = @oarapi;
                }

                location ~ ^/oarapi {
                  error_page 404 = @oarapi;
                }

                location @api {
                  rewrite ^/api-priv/?(.*)$ /$1 break;
                  rewrite ^/api/?(.*)$ /$1 break;
                  proxy_pass http://127.0.0.1:8080;
                  proxy_set_header Host $host;
                  # Only for http I guess
                  proxy_set_header X-Remote-Ident $http_remote_user;
                  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                }

                location ~ ^/api-priv {
                  auth_basic "OAR API Authentication";
                  auth_basic_user_file /etc/oar/api-users;
                  error_page 404 = @api;
                }

                location ~ ^/api {
                  error_page 404 = @api;
                }
              ''
              (optionalString cfg.web.monika.enable ''
                location =/monika.css {
                  alias ${oarVisualization}/monika/monika.css;
                }
                location ~ ^/monika {
                  gzip off;
                  rewrite ^/monika/?$ / break;
                  rewrite ^/monika/(.*)$ $1 break;
                  include ${pkgs.nginx}/conf/fastcgi_params;
                  fastcgi_pass ${fcgi.socketType}:${fcgi.socketAddress};
                  fastcgi_param SCRIPT_FILENAME ${oarVisualization}/monika/monika.cgi;
                  fastcgi_param PATH_INFO $fastcgi_script_name;
                }
              '')
              (optionalString cfg.web.drawgantt.enable ''
                location ~ ^/drawgantt {
                   #gzip off;
                   rewrite ^/drawgantt/?$ / break;
                   rewrite ^/drawgantt/(.*)$ $1 break;
                   fastcgi_index drawgantt.php;
                   include ${pkgs.nginx}/conf/fastcgi_params;
                   fastcgi_param SCRIPT_FILENAME ${oarVisualization}/drawgantt/$fastcgi_script_name;
                   fastcgi_pass unix:${config.services.phpfpm.pools.oar.socket};
                }
              '')
              (optionalString (cfg.web.extraConfig != "") ''
                ${cfg.web.extraConfig}
              '')
            ];
        };
      };

      services.uwsgi = mkIf cfg.web.enable {
        enable = true;
        plugins = [ "python3" ];
        user = "oar";
        group = "oar";
        instance = {
          type = "emperor";
          vassals.oar-api = {
            socket = "/run/uwsgi/oarapi.sock";
            type = "normal";
            master = true;
            workers = 2;
            # TODO: PATH variable suffered duplication, the bug is in nixpkgs/nixos/.../uwsgi.nix
            env = [ "PATH=/run/current-system/sw/bin/" ];
            module = "oarapi:application";
            chdir = pkgs.writeTextDir "oarapi.py" ''
              from oar.rest_api.app import wsgi_app as application
            '';
            pythonPackages = self: with self; [ pkgs.nur.repos.kapack.oar ];
          };
        };
      };

      services.unit = mkIf cfg.web.enable {
        enable = true;
        user = "oar";
        group = "oar";
        config =
          let
            app = pkgs.writeTextDir "asgi.py" ''
              from oar.api.app import app
            '';
            app_env =
              pkgs.python3.withPackages (ps: [ pkgs.nur.repos.kapack.oar ]);
          in
          pkgs.lib.strings.toJSON {
            listeners."*:8080" = {
              pass = "applications/fastapi";
              client_ip = {
                header = "X-Forwarded-For";
                source = [ "127.0.0.1" "0.0.0.0" ];
              };
            };
            applications.fastapi = {
              type = "python ${pkgs.python3.pythonVersion}";
              path = "${app}";
              home = "${app_env}";
              module = "asgi";
              callable = "app";
            };
          };
      };

      # fcgiwrap server to run CGI application, here Monika, over FastCGI.
      services.fcgiwrap = mkIf cfg.web.monika.enable {
        enable = true;
        preforkProcesses = 1;
        user = "oar";
        group = "oar";
      };

      services.phpfpm = lib.mkIf cfg.web.drawgantt.enable {
        pools.oar = {
          user = "oar";
          group = "oar";
          settings = lib.mapAttrs (name: lib.mkDefault) {
            "listen.owner" = "oar";
            "listen.group" = "oar";
            "listen.mode" = "0660";
            "pm" = "dynamic";
            "pm.start_servers" = 1;
            "pm.min_spare_servers" = 1;
            "pm.max_spare_servers" = 2;
            "pm.max_requests" = 50;
            "pm.max_children" = 5;
          };
        };
      };

      environment.etc."oar/monika-base.conf" = mkIf cfg.web.monika.enable {
        mode = "0600";
        source = monikaBaseConf;
      };
      environment.etc."oar/drawgantt-base.conf" =
        mkIf cfg.web.drawgantt.enable {
          mode = "0600";
          source = drawganttBaseConf;
        };

      systemd.services.oar-visu-conf-init =
        mkIf (cfg.web.monika.enable || cfg.web.drawgantt.enable) {
          wantedBy = [ "network.target" ];
          before = [ "network.target" ];
          serviceConfig.Type = "oneshot";
          script = concatStringsSep "\n" [
            ''
              mkdir -p /etc/oar
              source ${cfg.database.passwordFile}
            ''
            (optionalString cfg.web.monika.enable ''
              touch /etc/oar/monika.conf
              chmod 600 /etc/oar/monika.conf
              chown oar /etc/oar/monika.conf

              echo "username = $DB_BASE_LOGIN_RO" >> /etc/oar/monika.conf
              echo "password = $DB_BASE_PASSWD_RO" >> /etc/oar/monika.conf
              cat /etc/oar/monika-base.conf >> /etc/oar/monika.conf
            '')

            (optionalString cfg.web.drawgantt.enable ''
              touch /etc/oar/drawgantt-config.inc.php
              chmod 600 /etc/oar/drawgantt-config.inc.php
              chown oar /etc/oar/drawgantt-config.inc.php

              cp /etc/oar/drawgantt-base.conf /etc/oar/drawgantt-config.inc.php
              sed -i -e "s/DB_BASE_LOGIN_RO/$DB_BASE_LOGIN_RO/" /etc/oar/drawgantt-config.inc.php
              sed -i -e "s/DB_BASE_PASSWD_RO/$DB_BASE_PASSWD_RO/" /etc/oar/drawgantt-config.inc.php
            '')
          ];
        };

      systemd.tmpfiles.rules =
        mkIf cfg.web.proxy.enable [ "d '/etc/oar/proxy' - oar oar - -" ];

      systemd.services.oar-proxy-cleaner = mkIf cfg.web.proxy.enable {
        description = "OAR's proxy rules cleaner";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        #preStart = "touch /etc/oar/proxy/rules_oar_traefik.toml";
        environment.OARDIR = "${cfg.package}/bin";
        serviceConfig = {
          User = "oar";
          Group = "oar";
          ExecStart = "${cfg.package}/bin/oar-proxy-cleaner";
          KillMode = "process";
          Restart = "on-failure";
        };
      };

      systemd.services.oar-proxy-traefik = mkIf cfg.web.proxy.enable {
        description = "OAR's proxy rules cleaner";
        wantedBy = [ "multi-user.target" ];
        after = [ "network-online.target" ];
        preStart = "touch /etc/oar/proxy/rules_oar_traefik.toml";
        serviceConfig = {
          ExecStart =
            let
              configFile = pkgs.runCommand "config.toml"
                {
                  buildInputs = [ pkgs.remarshal ];
                  preferLocalBuild = true;
                } ''
                remarshal -if json -of toml \
                < ${
                  pkgs.writeText "config.json" (builtins.toJSON
                    (cfg.web.proxy.configOptions // {
                      entryPoints.http.address = cfg.web.proxy.entryPointHttp;
                    }))
                } \
                > $out
              '';
            in
            "${pkgs.traefik}/bin/traefik --configfile=${configFile}";
          Type = "simple";
          User = "oar";
          Group = "oar";
          Restart = "on-failure";
          StartLimitInterval = 86400;
          StartLimitBurst = 5;
        };
      };
      # services.traefik = mkIf cfg.web.proxy.enable {
      #   enable = true;
      #   configOptions = {
      #     #debug = true;
      #     #logLevel = "DEBUG";
      #     defaultentrypoints = [ "http"];
      #     # [api]
      #     # dashboard = true
      #     # entrypoint = "auth_api"
      #     wss.protocol = "http";
      #     file.filename = "/etc/oar/proxy/rules_oar_traefik.toml";
      #     file.watch = true;
      #     entryPoints.http.address = cfg.web.proxy.entryPointHttp;
      #   };
      #};
    };
}
