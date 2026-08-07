{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (lib)
    mkPackageOption
    mkEnableOption
    mkOption
    getExe
    types
    mkIf
    pipe
    mapAttrsRecursive
    optionalAttrs
    isList
    concatStringsSep
    isBool
    boolToString
    collect
    isString
    ;

  inherit (types)
    submodule
    attrs
    str
    port
    ;

  cfg = config.services.uptime-kuma-matrix;

  args = pipe cfg.settings [
    (mapAttrsRecursive (
      path: value:
      optionalAttrs (value != null) {
        name = concatStringsSep "-" path;
        value =
          if isList value then
            concatStringsSep "," value
          else if isBool value then
            boolToString value
          else
            toString value;
      }
    ))
    (collect (x: isString x.name or false && isString x.value or false))
    (map ({ name, value }: "-${name}=\"${value}\""))
    (concatStringsSep " ")
  ];
in
{
  options.services.uptime-kuma-matrix = {
    enable = mkEnableOption "uptime-kuma-matrix: Very simple UptimeKuma webhook receiver for Matrix written in Go";
    package = mkPackageOption pkgs "uptime-kuma-matrix" { };
    settings = mkOption {
      description = "Settings of the webhook receiver";
      type = submodule {
        freeformType = attrs;
        options = {
          addr = mkOption {
            description = "Host name where the webhook receiver should listen on";
            type = str;
            default = "127.0.0.1";
            example = "0.0.0.0";
          };
          port = mkOption {
            description = "Port where the webhook receiver should listen on";
            type = port;
            default = 1234;
            example = 12345;
          };
        };
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.services.uptime-kuma-matrix = {
      description = "uptime-kuma-matrix: Very simple UptimeKuma webhook receiver for Matrix written in Go.";
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "30s";
        DynamicUser = true;
        UMask = "0027";
        ExecStart = "${getExe cfg.package} ${args}";
        PrivateDevices = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictRealtime = true;
        LockPersonality = true;
        ProtectKernelLogs = true;
        ProtectKernelTunables = true;
        ProtectHostname = true;
        ProtectKernelModules = true;
        PrivateUsers = true;
        ProtectClock = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = "@system-service";
      };
    };
  };
}
