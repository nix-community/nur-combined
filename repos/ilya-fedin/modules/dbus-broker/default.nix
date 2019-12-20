{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.dbus-broker;
  dbusCfg = config.services.dbus;

  configDir = pkgs.makeDBusConf {
    suidHelper = "${config.security.wrapperDir}/dbus-daemon-launch-helper";
    serviceDirectories = dbusCfg.packages;
  };

  execStart = ''

    ExecStart=${pkgs.dbus-broker}/bin/dbus-broker-launch --config-file ${configDir}/system.conf --scope system --audit
  '';

  execStartUser = ''

    ExecStart=${pkgs.dbus-broker}/bin/dbus-broker-launch --config-file ${configDir}/session.conf --scope user
  '';
in {
  options = {
    services.dbus-broker = {
      enable = mkOption {
        type = types.bool;
        default = false;
        internal = true;
        description = ''
          Replace D-Bus message bus daemon with Linux D-Bus Message Broker, which is
          an implementation of a message bus as defined by the D-Bus specification.
          Its aim is to provide high performance and reliability, while keeping
          compatibility to the D-Bus reference implementation. It is exclusively
          written for Linux systems, and makes use of many modern features provided
          by recent linux kernel releases.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.dbus-broker ];
    systemd.packages = [ pkgs.dbus-broker ];

    services.dbus.enable = true;
    services.dbus.socketActivated = true;

    systemd.services = {
      dbus = {
        serviceConfig.ExecStart = execStart;
      };

      dbus-broker = {
        # Don't restart dbus-broker. Bad things tend to happen if we do.
        reloadIfChanged = true;
        restartTriggers = [ configDir ];
        environment = { LD_LIBRARY_PATH = config.system.nssModules.path; };
        serviceConfig.ExecStart = execStart;
        aliases = [ "dbus.service" ];
      };
    };

    systemd.user.services = {
      dbus = {
        serviceConfig.ExecStart = execStartUser;
      };

      dbus-broker = {
        # Don't restart dbus-broker. Bad things tend to happen if we do.
        reloadIfChanged = true;
        restartTriggers = [ configDir ];
        serviceConfig.ExecStart = execStartUser;
        aliases = [ "dbus.service" ];
      };
    };
  };
}
