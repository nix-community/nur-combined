{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.dbus-broker;
  dbusCfg = config.services.dbus;

  configDir = pkgs.makeDBusConf {
    suidHelper = "${config.security.wrapperDir}/dbus-daemon-launch-helper";
    serviceDirectories = dbusCfg.packages;
  };

  brokerPkg = pkgs.dbus-broker.overrideAttrs(_: {
    patches = [ ./use-right-paths.patch ];
  });
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
    environment.systemPackages = [ brokerPkg ];
    systemd.packages = [ brokerPkg ];

    services.dbus.enable = true;

    systemd.services.dbus-broker = {
      # Don't restart dbus-broker. Bad things tend to happen if we do.
      reloadIfChanged = true;
      restartTriggers = [ configDir ];
      environment = { LD_LIBRARY_PATH = config.system.nssModules.path; };
      aliases = [ "dbus.service" ];
    };

    systemd.user.services.dbus-broker = {
      # Don't restart dbus-broker. Bad things tend to happen if we do.
      reloadIfChanged = true;
      restartTriggers = [ configDir ];
      aliases = [ "dbus.service" ];
    };
  };
}
