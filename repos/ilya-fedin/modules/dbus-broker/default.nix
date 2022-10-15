{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.services.dbus-broker;
in {
  options = {
    services.dbus-broker = {
      enable = mkOption {
        type = types.bool;
        default = false;
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

    systemd.services.dbus-broker = {
      # Don't restart dbus-broker. Bad things tend to happen if we do.
      reloadIfChanged = true;
      restartTriggers = [ config.environment.etc."dbus-1".source ];
      environment = { LD_LIBRARY_PATH = config.system.nssModules.path; };
      aliases = [ "dbus.service" ];
    };

    systemd.user.services.dbus-broker = {
      # Don't restart dbus-broker. Bad things tend to happen if we do.
      reloadIfChanged = true;
      restartTriggers = [ config.environment.etc."dbus-1".source ];
      aliases = [ "dbus.service" ];
    };
  };
}
