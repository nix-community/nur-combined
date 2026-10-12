{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    # keep-sorted start
    getExe
    mkDefault
    mkEnableOption
    mkIf
    mkOption
    mkPackageOption
    optional
    replaceStrings
    types
    # keep-sorted end
    ;

  inherit (types)
    # keep-sorted start
    attrs
    enum
    ints
    listOf
    str
    strMatching
    submodule
    # keep-sorted end
    ;

  cfg = config.services.meshcoretomqtt;

  settingsFormat = pkgs.formats.toml { };
  configFile = settingsFormat.generate "meshcoretomqtt-config.toml" cfg.settings;
in
{
  options.services.meshcoretomqtt = {
    enable = mkEnableOption "MeshCore to MQTT bridge service";
    package = mkPackageOption pkgs "meshcoretomqtt" { };
    settings = mkOption {
      type = submodule {
        freeformType = attrs;
        options = {
          general = {
            iata = mkOption {
              description = "Three letter IATA code for geographic region";
              type = strMatching "^[A-Z]{3}$";
              example = "XXX";
            };
            log_level = mkOption {
              description = "The log level";
              type = enum [
                "CRITICAL"
                "ERROR"
                "WARNING"
                "INFO"
                "DEBUG"
                "NOTSET"
              ];
              example = "ERROR";
            };
            sync_time = mkEnableOption "syncing time";
          };
          serial = {
            ports = mkOption {
              description = "Serial ports to listen on (will be available to the meshcoretomqtt user)";
              type = listOf str;
              example = [
                "/dev/ttyACM0"
                "/dev/ttyACM1"
              ];
            };
            baud_rate = mkOption {
              description = "The baud rate of the connection with the serial port";
              type = ints.positive;
              example = 9600;
            };
            timeout = mkOption {
              description = "The timeout (in seconds) before the serial port connection should time out";
              type = ints.positive;
              example = 1;
            };
          };
        };
      };
      default = { };
      description = "Settings for the meshcoretomqtt daemon";
    };
    defaults = {
      letsmesh-us = mkEnableOption "LetsMesh US broker (mqtt-us-v1.letsmesh.net)";
      letsmesh-eu = mkEnableOption "LetsMesh EU broker (mqtt-eu-v1.letsmesh.net)";
    };
  };

  config = mkIf cfg.enable {
    services.meshcoretomqtt.settings = {
      general = {
        log_level = mkDefault "INFO";
        sync_time = mkDefault true;
      };
      serial = {
        ports = mkDefault [ "/dev/ttyACM0" ];
        baud_rate = mkDefault 115200;
        timeout = mkDefault 2;
      };
      topics = mkDefault {
        status = "meshcore/{IATA}/{PUBLIC_KEY}/status";
        packets = "meshcore/{IATA}/{PUBLIC_KEY}/packets";
        debug = "meshcore/{IATA}/{PUBLIC_KEY}/debug";
        raw = "meshcore/{IATA}/{PUBLIC_KEY}/raw";
      };
      broker =
        optional cfg.defaults.letsmesh-us {
          auth = {
            audience = "mqtt-us-v1.letsmesh.net";
            method = "token";
          };
          enabled = true;
          keepalive = 60;
          name = "letsmesh-us";
          port = 443;
          qos = 0;
          retain = true;
          server = "mqtt-us-v1.letsmesh.net";
          tls = {
            enabled = true;
            verify = true;
          };
          transport = "websockets";
        }
        ++ optional cfg.defaults.letsmesh-eu {
          auth = {
            audience = "mqtt-eu-v1.letsmesh.net";
            method = "token";
          };
          enabled = true;
          keepalive = 60;
          name = "letsmesh-eu";
          port = 443;
          qos = 0;
          retain = true;
          server = "mqtt-eu-v1.letsmesh.net";
          tls = {
            enabled = true;
            verify = true;
          };
          transport = "websockets";
        };
    };

    users.users.meshcoretomqtt = {
      isSystemUser = true;
      group = "meshcoretomqtt";
      description = "MeshCore to MQTT bridge service user";
      extraGroups = [ "dialout" ];
    };
    users.groups.meshcoretomqtt = { };

    systemd.services.meshcoretomqtt = {
      description = "MeshCore to MQTT Bridge";
      wantedBy = [ "multi-user.target" ];
      requires = map (
        port: "dev-${replaceStrings [ "/dev/" ] [ "" ] port}.device"
      ) cfg.settings.serial.ports;
      after = [
        "network.target"
      ]
      ++ map (port: "dev-${replaceStrings [ "/dev/" ] [ "" ] port}.device") cfg.settings.serial.ports;
      serviceConfig = {
        Type = "simple";
        ExecStart = "${getExe cfg.package} --config ${configFile}";
        Restart = "on-failure";
        User = "meshcoretomqtt";
        Group = "meshcoretomqtt";
        StateDirectory = "meshcoretomqtt";
        CacheDirectory = "meshcoretomqtt";
        LogsDirectory = "meshcoretomqtt";
        WorkingDirectory = "%S";
        ReadWritePaths = [
          "/var/lib/meshcoretomqtt"
          "/var/cache/meshcoretomqtt"
          "/var/log/meshcoretomqtt"
        ]
        ++ cfg.settings.serial.ports;
        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MountAPIVFS = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateMounts = true;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = "strict";
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = "AF_INET AF_INET6 AF_UNIX";
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        UMask = 27;
      };
    };
  };
}
