{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.dell-command-monitor;

  omi = cfg.package.omi;
  hapi = cfg.package.srvadmin-hapi;

  stateDir = "/var/lib/dell-command-monitor";
  logDir = "/var/log/dell-command-monitor";

  # OMI's provider and registration directories, which upstream populates by
  # running `omireg` from postinst. `--link` symlinks the provider libraries
  # instead of copying them, so the whole thing can live in the store.
  providers =
    pkgs.runCommand "dell-command-monitor-omi-providers"
      {
        nativeBuildInputs = [ omi ];
      }
      ''
        mkdir -p $out/lib
        ln -s ${omi}/lib/* $out/lib
        cp -r ${omi}/etc/opt/omi/conf/omiregister $out/omiregister
        chmod -R u+w $out/omiregister

        # omireg refuses to run without a config file, and only looks for it
        # under /etc/opt/omi or as ./.omiregrc.
        cp ${omi}/etc/opt/omi/conf/omireg.conf .omiregrc
        for provider in libDellSysMgmtProv libDellSysMgmtAlertProv; do
          omireg \
            --registerdir $out/omiregister \
            --providerdir $out/lib \
            --link \
            -n root/dcim/sysman \
            ${cfg.package}/lib/$provider.so
        done
      '';

  # HAPI hard-codes this one path, but everything else it uses is read from it.
  omregCfg = pkgs.runCommand "omreg.cfg" { } ''
    sed \
      -e 's|^hapi.configtool=.*|hapi.configtool=${hapi}/sbin/dchcfg|' \
      -e 's|^hapi.installpath=.*|hapi.installpath=${hapi}|' \
      -e 's|^hapi.logpath=.*|hapi.logpath=${logDir}/openmanage|' \
      -e 's|^hapi.vardatapath=.*|hapi.vardatapath=${stateDir}/hapi|' \
      -e 's|^hapi.inipath=.*|hapi.inipath=${stateDir}/hapi/ini|' \
      ${hapi}/etc/omreg.cfg > $out
  '';

  # Files the providers may rewrite (asset/location info, inventory snapshots).
  mutableConfigFiles = [
    "AlertPollingSettings.ini"
    "Asset.ini"
    "DeviceInventory.ini"
    "Location.ini"
  ];
  staticConfigFiles = [
    "BIOSSettings.xml"
    "log.property"
    "pci.ids"
  ];

  settingsFormat = pkgs.formats.keyValue { };
in
{
  options.services.dell-command-monitor = {
    enable = lib.mkEnableOption "Dell Command | Monitor, served over OMI";

    package = lib.mkPackageOption pkgs "dell-command-monitor" { };

    settings = lib.mkOption {
      inherit (settingsFormat) type;
      default = { };
      example = {
        httpsport = 5986;
        loglevel = "INFO";
      };
      description = ''
        Contents of `/etc/opt/omi/conf/omiserver.conf`. See the comments in
        `''${cfg.package.omi}/etc/opt/omi/conf/omiserver.conf` for available
        keys. By default OMI only listens on its local socket.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.dell-command-monitor.settings = {
      httpport = lib.mkDefault 0;
      httpsport = lib.mkDefault 0;
      sslciphersuite = lib.mkDefault "ALL:!SSLv2:!SSLv3:!TLSv1:!TLSv0:!CBC:!RC4-MD5:!RC4-SHA:!SEED-SHA";

      # Point OMI at the store instead of /opt/omi.
      bindir = "${omi}/bin";
      libdir = "${omi}/lib";
      agentprogram = "${omi}/bin/omiagent";
      serverprogram = "${omi}/bin/omiserver";
      providerdir = "${providers}/lib";
      registerdir = "/etc/opt/omi/conf/omiregister";
    };

    boot.kernelModules = [
      "dcdbas"
      "dell_rbu"
    ];

    environment.systemPackages = [ omi ];

    environment.etc = {
      "opt/omi/conf/omiserver.conf".source = settingsFormat.generate "omiserver.conf" cfg.settings;
      "opt/omi/conf/omicli.conf".source = "${omi}/etc/opt/omi/conf/omicli.conf";
      "opt/omi/conf/omiregister".source = "${providers}/omiregister";
    };

    users.users.omi = {
      isSystemUser = true;
      group = "omi";
    };
    users.groups.omi = { };
    users.groups.omiusers = { };

    # Used for HTTP(S) basic authentication, when enabled.
    security.pam.services.omi = { };

    systemd.tmpfiles.settings."10-dell-command-monitor" =
      let
        dir = user: group: mode: { d = { inherit user group mode; }; };
      in
      {
        "/etc/opt/omi/ssl" = dir "root" "root" "0755";
        "/etc/opt/omi/creds" = dir "omi" "omi" "0500";
        "/etc/opt/omi/conf/sockets" = dir "omi" "omi" "0700";
        "/var/opt/omi" = dir "root" "root" "0755";
        "/var/opt/omi/log" = dir "omi" "omi" "0755";
        "/var/opt/omi/run" = dir "omi" "omi" "0755";
        "/var/opt/omi/omiusers" = dir "root" "omiusers" "0775";

        "/opt/dell/srvadmin/etc" = dir "root" "root" "0755";
        "/opt/dell/srvadmin/etc/omreg.cfg".L.argument = "${omregCfg}";
        "${stateDir}/hapi" = dir "root" "root" "0755";
        "${stateDir}/hapi/ini" = dir "root" "root" "0755";
        "${stateDir}/hapi/ini/dchipm.ini".C = {
          argument = "${hapi}/etc/srvadmin-hapi/ini/dchipm.ini";
          mode = "0644";
        };
        "${logDir}/openmanage" = dir "root" "root" "0755";

        "/opt/dell/dcm" = dir "root" "root" "0755";
        "/opt/dell/dcm/conf".L.argument = "${stateDir}/conf";
        "/opt/dell/dcm/var" = dir "root" "root" "0755";
        "/opt/dell/dcm/var/log".L.argument = logDir;
        "${stateDir}/conf" = dir "root" "root" "0755";
        "${logDir}" = dir "root" "root" "0755";
      }
      // lib.genAttrs' mutableConfigFiles (
        name:
        lib.nameValuePair "${stateDir}/conf/${name}" {
          C = {
            argument = "${cfg.package}/etc/dcm/${name}";
            mode = "0644";
          };
        }
      )
      // lib.genAttrs' staticConfigFiles (
        name:
        lib.nameValuePair "${stateDir}/conf/${name}" {
          "L+".argument = "${cfg.package}/etc/dcm/${name}";
        }
      );

    systemd.services.omid = {
      description = "OMI CIM Server";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      restartTriggers = [
        config.environment.etc."opt/omi/conf/omiserver.conf".source
        providers
        omregCfg
      ];

      path = [ pkgs.openssl ];
      # Upstream postinst generates a self-signed certificate on install.
      preStart = ''
        if [ ! -f /etc/opt/omi/ssl/omikey.pem ] || [ ! -f /etc/opt/omi/ssl/omi.pem ]; then
          openssl req -x509 -sha256 -newkey rsa:3072 -days 3650 -nodes \
            -subj "/CN=${config.networking.hostName}/CN=${config.networking.fqdnOrHostName}" \
            -keyout /etc/opt/omi/ssl/omikey.pem -out /etc/opt/omi/ssl/omi.pem
          chown omi:omi /etc/opt/omi/ssl/omikey.pem
          chmod 600 /etc/opt/omi/ssl/omikey.pem
          chmod 644 /etc/opt/omi/ssl/omi.pem
        fi
      '';

      serviceConfig = {
        ExecStart = "${omi}/bin/omiserver";
        ExecReload = "${omi}/bin/omiserver -r";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    services.logrotate.settings.omi = {
      files = [
        "/var/opt/omi/log/*.log"
        "/var/opt/omi/log/*.trc"
      ];
      rotate = 5;
      missingok = true;
      notifempty = true;
      compress = true;
      size = "100M";
      copytruncate = true;
    };
  };
}
