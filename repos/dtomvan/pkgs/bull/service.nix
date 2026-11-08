{
  lib,
  config,
  options,
  ...
}:
let
  inherit (lib)
    getExe'
    mkOption
    optionalAttrs
    ;

  inherit (lib.types)
    package
    listOf
    str
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

    extraArgs = mkOption {
      description = "Extra arguments passed to bull";
      default = [ ];
      type = listOf str;
    };

    content = mkOption {
      description = "Directory where the content goes.";
      type = str;
    };

    listen = mkOption {
      description = "Address to listen on.";
      default = "127.0.0.1:3333";
      type = str;
    };
  };

  config = {
    process.argv = [
      (getExe' cfg.package "bull")
      "--content"
      cfg.content
      "serve"
      "--listen=${cfg.listen}"
    ]
    ++ cfg.extraArgs;
  }
  // optionalAttrs (options ? systemd) {
    systemd.service = {
      after = [ "network.target" ];
      wants = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Restart = "always";
        RequiresMountsFor = [ cfg.content ];

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
