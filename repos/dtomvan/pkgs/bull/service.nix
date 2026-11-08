# Non-module dependencies (`importApply`)
{ pkgs, ... }:

# Service module
{
  lib,
  config,
  options,
  ...
}:
let
  inherit (builtins) concatStringsSep;

  inherit (lib)
    escapeShellArg
    getExe
    mkOption
    optionalAttrs
    singleton
    ;

  inherit (lib.types)
    package
    str
    port
    ;

  cfg = config.bull;
in
{
  # https://nixos.org/manual/nixos/unstable/#modular-services
  _class = "service";

  options.bull = {
    package = mkOption {
      description = "Package to use for ghostunnel";
      defaultText = "The ghostunnel package that provided this module.";
      type = package;
    };

    port = mkOption {
      description = "Port to listen on.";
      default = 3333;
      type = port;
    };

    userId = mkOption {
      description = "User ID to connect with.";
      type = str;
    };
  };

  config = {
    process.argv = [ (getExe cfg.packge) ];
  }
  // optionalAttrs (options ? systemd) {
    systemd.service = {
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "always";

        # hardening BS
        DynamicUser = true;
        ProtectHome = true;
        MemoryDenyWriteExecute = true;
        PrivateDevices = true;
        PrivateTmp = true;
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
