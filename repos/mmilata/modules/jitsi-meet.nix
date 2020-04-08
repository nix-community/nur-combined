{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.jitsi-meet;
  dataDir = "/var/lib/jitsi-meet";
  attrsToArgs = a: concatStringsSep " " (mapAttrsToList (k: v: "${k}=${toString v}") a);

  # HOCON is a JSON superset that videobridge2 uses for configuration
  # it can substitute environment variables which we use for passwords here
  # https://github.com/lightbend/config/blob/master/README.md
  toHOCON = v: builtins.replaceStrings [ ''"__ENV__'' ''__ENV__"'' ] [ "\${" "}" ] (builtins.toJSON v);
  jvbArgs = {
    "--apis" = "none";
  };
  jvbProps = {
    "-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION" = "/etc/jitsi";
    "-Dnet.java.sip.communicator.SC_HOME_DIR_NAME" = "videobridge";
    "-Djava.util.logging.config.file" = "/etc/jitsi/videobridge/logging.properties";
    "-Dconfig.file" = pkgs.writeText "jvb.conf" (toHOCON jvbConfig);
  } // (mapAttrs' (k: v: nameValuePair "-D${k}" v) cfg.videobridge.extraProperties);
  jvbConfig = recursiveUpdate defaultJvbConfig cfg.videobridge.config;

  jicofoArgs = {
    "--host" = "localhost";
    "--domain" = cfg.hostName;
    "--secret" = "\${JICOFO_COMPONENT_SECRET}";
    "--user_domain" = "auth.${cfg.hostName}";
    "--user_name" = "focus";
    "--user_password" = "\${JICOFO_USER_SECRET}";
  };
  jicofoProps = {
    "-Dnet.java.sip.communicator.SC_HOME_DIR_LOCATION" = "/etc/jitsi";
    "-Dnet.java.sip.communicator.SC_HOME_DIR_NAME" = "jicofo";
    "-Djava.util.logging.config.file" = "/etc/jitsi/jicofo/logging.properties";
    "-Djavax.net.ssl.trustStore" = "${dataDir}/prosody-ca.jks";
    "-Djavax.net.ssl.trustStorePassword" = "javapls";
  };
  jicofoConfig = pkgs.writeText "sip-communicator.properties" (
    concatStringsSep "\n" (mapAttrsToList (k: v: "${k}=${v}") cfg.jicofo.config)
  );

  # The configuration files are JS of format "var <<string>> = <<JSON>>;". In order to
  # override only some settings, we need to extract the JSON, use jq to merge it with
  # the config provided by user, and then reconstruct the file.
  overrideJs =
    source: varName: userCfg:
    let
      extractor = pkgs.writeText "extractor.js" ''
        var fs = require("fs");
        eval(fs.readFileSync(process.argv[2], 'utf8'));
        process.stdout.write(JSON.stringify(eval(process.argv[3])));
      '';
      userJson = pkgs.writeText "user.json" (builtins.toJSON userCfg);
    in (pkgs.runCommand "${varName}.js" { } ''
      ${pkgs.nodejs}/bin/node ${extractor} ${source} ${varName} > default.json
      (
        echo "var ${varName} = "
        ${pkgs.jq}/bin/jq -s '.[0] * .[1]' default.json ${userJson}
        echo ";"
      ) > $out
    '');

  # Essential config - it's probably not good to have these as option default because
  # types.attrs doesn't do merging. Let's merge explicitly, can still be overriden if
  # user desires.
  defaultCfg = {
    hosts = {
      domain = cfg.hostName;
      muc = "conference.${cfg.hostName}";
    };
    bosh = "//${cfg.hostName}/http-bind";
  };

  defaultJvbConfig = {
    videobridge = {
      apis.xmpp-client.configs.xmppserver1 = {
        hostname = "localhost";
        domain = "auth.${cfg.hostName}";
        username = "jvb";
        password = "__ENV__VIDEOBRIDGE_SECRET__ENV__";
        muc_jids = "jvbbrewery@internal.${cfg.hostName}";
        muc_nickname = builtins.replaceStrings [ "." ] [ "-" ] (
          config.networking.hostName + optionalString (config.networking.domain != null) ".${config.networking.domain}"
        );
        disable_certificate_verification = true;
      };
      ice = {
        tcp = {
          enabled = true;
          port = 4443;
        };
        udp.port = 10000;
      };
      stats = {
        enabled = true;
        transports = [ { type = "muc"; } ];
      };
    };
  };

in
{
  options.services.jitsi-meet = with types; {
    enable = mkEnableOption "Jitsi Meet - Secure, Simple and Scalable Video Conferences";

    hostName = mkOption {
      type = str;
      example = "meet.example.org";
      description = ''
        Hostname of the Jitsi Meet instance.
      '';
    };

    package = mkOption {
      type = package;
      default = pkgs.callPackage ../pkgs/jitsi-meet { };
    };

    config = mkOption {
      type = attrs;
      default = { };
      example = literalExample ''
        {
          enableWelcomePage = false;
          defaultLang = "fi";
        }
      '';
      description = ''
        Client-side web application settings that override the defaults in <filename>config.js</filename>.

        See <link xlink:href="https://github.com/jitsi/jitsi-meet/blob/master/config.js" /> for default
        configuration with comments.
      '';
    };

    interfaceConfig = mkOption {
      type = attrs;
      default = { };
      example = literalExample ''
        {
          SHOW_JITSI_WATERMARK = false;
          SHOW_WATERMARK_FOR_GUESTS = false;
        }
      '';
      description = ''
        Client-side web-app interface settings that override the defaults in <filename>interface_config.js</filename>.

        See <link xlink:href="https://github.com/jitsi/jitsi-meet/blob/master/interface_config.js" /> for
        default configuration with comments.
      '';
    };

    videobridge = {
      config = mkOption {
        type = attrs;
        default = { };
        example = literalExample ''
          {
            videobridge = {
              ice.udp.port = 5000;
              websockets = {
                enabled = true;
                server-id = "jvb1";
              };
            };
          }
        '';
        description = ''
          Videobridge configuration.

          See <link xlink:href="https://github.com/jitsi/jitsi-videobridge/blob/master/src/main/resources/reference.conf" />
          for default configuration with comments.
        '';
      };

      extraProperties = mkOption {
        type = attrsOf str;
        default = { };
        example = literalExample ''
          {
            "org.ice4j.ice.harvest.NAT_HARVESTER_LOCAL_ADDRESS" = "192.168.1.42";
            "org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS" = "1.2.3.4";
          }
        '';
        description = ''
          Additional Java properties passed to jitsi-videobridge.

          The following extra properties need to be added when running behind NAT:

          <programlisting>
          org.ice4j.ice.harvest.NAT_HARVESTER_LOCAL_ADDRESS = <replaceable>Local.IP.Address</replaceable>
          org.ice4j.ice.harvest.NAT_HARVESTER_PUBLIC_ADDRESS = <replaceable>Public.IP.Address</replaceable>
          </programlisting>
        '';
      };

      package = mkOption {
        type = package;
        default = pkgs.callPackage ../pkgs/jitsi-videobridge { };
        #defaultText = "pkgs.jitsi-videobridge";
      };

      openFirewall = mkOption {
        type = bool;
        default = false;
        description = ''
          Whether to open ports in the firewall for the videobridge.
        '';
      };
    };

    jicofo = {
      config = mkOption {
        type = attrsOf str;
        default = { };
        example = literalExample ''
          {
            "org.jitsi.jicofo.ALWAYS_TRUST_MODE_ENABLED" = "true";
            "org.jitsi.jicofo.auth.URL" = "XMPP:jitsi-meet.example.com";
          }
        '';
        description = ''
          Contents of the <filename>sip-communicator.properties</filename> configuration file for jicofo.
        '';
      };

      package = mkOption {
        type = package;
        default = pkgs.callPackage ../pkgs/jicofo { };
        #defaultText = "pkgs.jicofo";
      };
    };

    nginx.enable = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether to enable nginx virtual host that will serve the javascript application and act as
        a proxy for the XMPP server. Further nginx configuration can be done by adapting
        <option>services.nginx.virtualHosts.&lt;hostName&gt;</option>. It is highly recommended to
        enable the <option>enableACME</option> and <option>forceSSL</option> options:

        <programlisting>
        services.nginx.virtualHosts.''${config.services.jitsi-meet.hostName} = {
          enableACME = true;
          forceSSL = true;
        };
        </programlisting>
      '';
    };

    prosody.enable = mkOption {
      type = bool;
      default = true;
      description = ''
        Whether to configure Prosody to relay XMPP messages between Jitsi Meet components. Turn this
        off if you want to configure it manually.
      '';
    };
  };

  config = mkIf cfg.enable {
    services.jitsi-meet.jicofo.config = mapAttrs (_: v: mkDefault v) {
      "org.jitsi.jicofo.BRIDGE_MUC" = "jvbbrewery@internal.${cfg.hostName}";
    };

    services.prosody = mkIf cfg.prosody.enable {
      enable = mkDefault true;
      modules = {
        admin_adhoc = mkDefault false;
        bosh = mkDefault true;
        ping = mkDefault true;
        roster = mkDefault true;
        saslauth = mkDefault true;
        tls = mkDefault true;
      };
      extraModules = [ "pubsub" ];
      extraConfig = ''
        certificates = "${config.services.prosody.dataDir}"

        Component "conference.${cfg.hostName}" "muc"
          storage = "memory"
          -- modules: muc_meeting_id muc_domain_mapper

          muc_room_locking = false
          muc_room_default_public_jids = true

        Component "internal.${cfg.hostName}" "muc"
          storage = "memory"
          -- muc_room_cache_size = 1000
          admins = { "focus@auth.${cfg.hostName}", "jvb@auth.${cfg.hostName}" }

        Component "focus.${cfg.hostName}"
          component_secret = os.getenv("JICOFO_COMPONENT_SECRET")
      '';
      virtualHosts.${cfg.hostName} = {
        enabled = true;
        domain = cfg.hostName;
        extraConfig = ''
          authentication = "anonymous"
          c2s_require_encryption = false
          admins = { "focus@auth.${cfg.hostName}" }
        '';
      };
      virtualHosts."auth.${cfg.hostName}" = {
        enabled = true;
        domain = "auth.${cfg.hostName}";
        extraConfig = ''
          authentication = "internal_plain"
        '';
      };
    };
    systemd.services.prosody.serviceConfig = mkIf cfg.prosody.enable {
      EnvironmentFile = [ "${dataDir}/secrets" ];
      SupplementaryGroups = [ "jitsi-meet" ];
    };

    users.groups.jitsi-meet = {};
    systemd.tmpfiles.rules = [
      "d '${dataDir}' 0750 root jitsi-meet - -"
    ];

    systemd.services.jitsi-meet-init-secrets = {
      wantedBy = [ "multi-user.target" ];
      before = [ "jicofo.service" "jitsi-videobridge2.service" ] ++ (optional cfg.prosody.enable "prosody.service");
      serviceConfig = {
        Type = "oneshot";
      };

      script = let
        secrets = [ "VIDEOBRIDGE_SECRET" "JICOFO_COMPONENT_SECRET" "JICOFO_USER_SECRET" ];
      in
      ''
        if [ ! -f ${dataDir}/secrets ]; then
          ${concatMapStringsSep "\n" (var: ''
            echo "${var}=$(tr -dc a-zA-Z0-9 </dev/urandom | head -c 64)" >> ${dataDir}/secrets
          '') secrets}

          chown root:jitsi-meet ${dataDir}/secrets
          chmod 640 ${dataDir}/secrets
        fi

      ''
      + optionalString cfg.prosody.enable ''
        source ${dataDir}/secrets
        ${config.services.prosody.package}/bin/prosodyctl register focus auth.${cfg.hostName} "$JICOFO_USER_SECRET"
        ${config.services.prosody.package}/bin/prosodyctl register jvb auth.${cfg.hostName} "$VIDEOBRIDGE_SECRET"

        cd ${config.services.prosody.dataDir}

        # regenerate the certificates after 1 month - they are valid for a year, that leaves 11 months for service restart
        find ${cfg.hostName}.crt -mtime +30 -delete || true

        # generate self-signed certificates
        if [ ! -f ${cfg.hostName}.crt ]; then
          export PATH=$PATH:${pkgs.openssl.bin}/bin
          rm -f {,auth.}${cfg.hostName}.{crt,key,cnf}
          # not sure this one is even used but it avoids some errors in logs
          echo | ${config.services.prosody.package}/bin/prosodyctl cert generate ${cfg.hostName}
          # used for jicofo<->prosody user connection
          echo | ${config.services.prosody.package}/bin/prosodyctl cert generate auth.${cfg.hostName}
        fi

        # don't know how to add it to the system-wide ceritificate bundle, instead convert it to java truststore and pass it to jicofo
        rm -f ${dataDir}/prosody-ca.jks
        ${pkgs.jre}/bin/keytool -importcert -file auth.${cfg.hostName}.crt -keystore ${dataDir}/prosody-ca.jks -storepass javapls -noprompt
        chown root:jitsi-meet ${dataDir}/prosody-ca.jks
      '';
    };

    services.nginx = mkIf cfg.nginx.enable {
      enable = mkDefault true;
      virtualHosts.${cfg.hostName} = {
        root = cfg.package;
        locations."~ ^/([a-zA-Z0-9=\\?]+)$" = {
          extraConfig = ''
            rewrite ^/(.*)$ / break;
          '';
        };
        locations."/" = {
          index = "index.html";
          extraConfig = ''
            ssi on;
          '';
        };
        locations."/http-bind" = {
          proxyPass = "http://localhost:5280/http-bind";
          extraConfig = ''
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;
          '';
        };
        locations."=/external_api.js" = {
          alias = "${cfg.package}/libs/external_api.min.js";
        };
        locations."=/config.js" = {
          alias = overrideJs "${cfg.package}/config.js" "config" (recursiveUpdate defaultCfg cfg.config);
        };
        locations."=/interface_config.js" = {
          alias = overrideJs "${cfg.package}/interface_config.js" "interfaceConfig" cfg.interfaceConfig;
        };
      };
    };

    systemd.services.jitsi-videobridge2 = {
      aliases = [ "jitsi-videobridge.service" ];
      description = "Jitsi Videobridge";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      environment.JAVA_SYS_PROPS = attrsToArgs jvbProps;

      serviceConfig = {
        Type = "exec";
        ExecStart = "${cfg.videobridge.package}/bin/jitsi-videobridge ${attrsToArgs jvbArgs}";

        DynamicUser = true;
        User = "jitsi-videobridge";
        Group = "jitsi-videobridge";
        SupplementaryGroups = [ "jitsi-meet" ];

        EnvironmentFile = [ "${dataDir}/secrets" ];

        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;

        TasksMax = 65000;
        LimitNPROC = 65000;
        LimitNOFILE = 65000;
      };
    };

    environment.etc."jitsi/videobridge/logging.properties".source =
      mkDefault "${cfg.videobridge.package}/etc/jitsi/videobridge/logging.properties-journal";

    # (from videobridge2 .deb)
    # this sets the max, so that we can bump the JVB UDP single port buffer size.
    boot.kernel.sysctl."net.core.rmem_max" = mkDefault 10485760;
    boot.kernel.sysctl."net.core.netdev_max_backlog" = mkDefault 100000;

    networking.firewall.allowedTCPPorts = mkIf cfg.videobridge.openFirewall
      [ jvbConfig.videobridge.ice.tcp.port ];
    networking.firewall.allowedUDPPorts = mkIf cfg.videobridge.openFirewall
      [ jvbConfig.videobridge.ice.udp.port ];

    systemd.services.jicofo = {
      description = "JItsi COnference FOcus";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartTriggers = [ jicofoConfig ];
      environment.JAVA_SYS_PROPS = attrsToArgs jicofoProps;

      serviceConfig = {
        Type = "exec";
        ExecStart = "${cfg.jicofo.package}/bin/jicofo ${attrsToArgs jicofoArgs}";

        DynamicUser = true;
        User = "jicofo";
        Group = "jicofo";
        SupplementaryGroups = [ "jitsi-meet" ];

        EnvironmentFile = [ "${dataDir}/secrets" ];

        CapabilityBoundingSet = "";
        NoNewPrivileges = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        ProtectHostname = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictAddressFamilies = [ "AF_INET" "AF_INET6" "AF_UNIX" ];
        RestrictNamespaces = true;
        LockPersonality = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
      };
    };

    environment.etc."jitsi/jicofo/sip-communicator.properties".source = jicofoConfig;
    environment.etc."jitsi/jicofo/logging.properties".source =
      mkDefault "${cfg.jicofo.package}/etc/jitsi/jicofo/logging.properties-journal";

    assertions = [{
      message = "Strings that start with __ENV__ must also end with __ENV__";
      assertion = let
        p = x: if isString x then (hasPrefix "__ENV__" x) == (hasSuffix "__ENV__" x)
          else if isList x then builtins.all p x
          else if isAttrs x then p (builtins.attrValues x)
          else true;
      in p jvbConfig;
    }];
  };

  meta.maintainers = with lib.maintainers; [ mmilata ];
}
