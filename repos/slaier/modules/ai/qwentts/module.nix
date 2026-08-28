{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.qwentts;
in
{
  options = {
    services.qwentts = {
      enable = lib.mkEnableOption "Qwen TTS HTTP server (tts-server)";

      package = lib.mkPackageOption pkgs "qwentts" { };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = lib.types.attrsOf (
            lib.types.oneOf [
              lib.types.str
              lib.types.int
              lib.types.float
              lib.types.bool
              lib.types.path
            ]
          );
          options = {
            model = lib.mkOption {
              type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
              default = null;
              example = "/var/lib/qwentts/qwen-talker.gguf";
              description = "Talker LM GGUF file (--model). Required when the service is enabled.";
            };

            codec = lib.mkOption {
              type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
              default = null;
              example = "/var/lib/qwentts/qwen-tokenizer.gguf";
              description = "Codec GGUF file (--codec). Required when the service is enabled.";
            };

            host = lib.mkOption {
              type = lib.types.str;
              default = "127.0.0.1";
              example = "0.0.0.0";
              description = "IP address to listen on (--host).";
            };

            port = lib.mkOption {
              type = lib.types.port;
              default = 8080;
              example = 8088;
              description = "Port to listen on (--port).";
            };

            alias = lib.mkOption {
              type = lib.types.nullOr lib.types.str;
              default = null;
              example = "qwen3-tts";
              description = "Model alias reported to clients (--alias).";
            };

            lang = lib.mkOption {
              type = lib.types.str;
              default = "auto";
              example = "Chinese";
              description = "Language label (--lang).";
            };

            max-batch = lib.mkOption {
              type = lib.types.nullOr lib.types.int;
              default = null;
              example = 1;
              description = "Maximum number of concurrent batches on GPU (--max-batch).";
            };

            no-fa = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Disable flash attention (--no-fa).";
            };

            clamp-fp16 = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Clamp hidden states to FP16 range (--clamp-fp16).";
            };

            codec-chunk-dur = lib.mkOption {
              type = lib.types.nullOr lib.types.float;
              default = null;
              example = 24.0;
              description = "Codec decode chunk duration in seconds (--codec-chunk-dur).";
            };
          };
        };
        default = { };
        example = {
          model = "/var/lib/qwentts/talker.gguf";
          codec = "/var/lib/qwentts/codec.gguf";
          host = "0.0.0.0";
          port = 8088;
          alias = "qwen3-tts";
          lang = "Chinese";
        };
        description = ''
          Command-line arguments for tts-server.

          See tts-server --help and https://github.com/ServeurpersoCom/qwentts.cpp for details.
        '';
      };

      openFirewall = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Whether to open the firewall for the configured port.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.settings.model != null;
        message = "services.qwentts.settings.model is required (Talker GGUF).";
      }
      {
        assertion = cfg.settings.codec != null;
        message = "services.qwentts.settings.codec is required (Codec GGUF).";
      }
    ];

    systemd.services.qwentts = {
      description = "Qwen TTS HTTP server (tts-server)";
      wants = [ "network.target" ];
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        ExecStart = toString [
          (lib.getExe' cfg.package "tts-server")
          (lib.cli.toCommandLine (optionName: {
            option = if builtins.stringLength optionName > 1 then "--${optionName}" else "-${optionName}";
            sep = " ";
            explicitBool = false;
            formatArg = lib.generators.mkValueStringDefault { };
          }) (lib.filterAttrs (_: v: v != null) cfg.settings))
        ];
        Restart = "on-failure";
        RestartSec = 5;

        DynamicUser = true;
        StateDirectory = "qwentts";
        CacheDirectory = "qwentts";
        WorkingDirectory = "/var/lib/qwentts";

        AmbientCapabilities = [ "" ];
        CapabilityBoundingSet = [ "" ];
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = false;
        PrivateMounts = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_INET"
          "AF_INET6"
          "AF_UNIX"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallErrorNumber = "EPERM";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall cfg.settings.port;
  };
}
