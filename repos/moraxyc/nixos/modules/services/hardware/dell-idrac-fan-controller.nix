{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.dell-idrac-fan-controller;

  toEnvValue = value: if lib.isBool value then lib.boolToString value else toString value;

  # Network mode can also be configured via environmentFile, so treat it conservatively when set.
  isNetworkMode = cfg.settings.IDRAC_HOST != "local" || cfg.environmentFile != null;
  isNetworkOnly = cfg.settings.IDRAC_HOST != "local" && cfg.environmentFile == null;

  envSettings =
    lib.mapAttrs (_name: value: if value == null then "" else toEnvValue value) (
      lib.filterAttrs (
        name: value: value != null || name == "MAXIMUM_IPMI_UNREACHABLE_DURATION"
      ) cfg.settings
    )
    // {
      HEARTBEAT_FILE = "/run/dell-idrac-fan-controller/heartbeat";
    };
in
{
  meta.maintainers = with lib.maintainers; [ moraxyc ];

  options.services.dell-idrac-fan-controller = {
    enable = lib.mkEnableOption "Dell iDRAC fan controller";

    package = lib.mkPackageOption pkgs "dell-idrac-fan-controller" { };

    environmentFile = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      example = "/run/secrets/dell-idrac-fan-controller.env";
      description = ''
        Environment file read by systemd. Use this for secrets such as
        `IDRAC_USERNAME` and `IDRAC_PASSWORD` instead of setting them in
        {option}`services.dell-idrac-fan-controller.settings`. Values in this
        file override {option}`services.dell-idrac-fan-controller.settings`.
      '';
    };

    settings = lib.mkOption {
      type = lib.types.submodule {
        freeformType =
          with lib.types;
          attrsOf (oneOf [
            bool
            int
            str
          ]);

        options = {
          IDRAC_HOST = lib.mkOption {
            type = lib.types.str;
            default = "local";
            example = "192.168.1.100";
            description = ''
              Target iDRAC host: `"local"` to use the host's local IPMI device
              (`/dev/ipmi0`), or the hostname/IP address of a remote iDRAC.
            '';
          };

          IDRAC_USERNAME = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            example = "root";
            description = ''
              iDRAC username for network mode (`IDRAC_HOST != "local"`).
              Prefer {option}`services.dell-idrac-fan-controller.environmentFile`
              to avoid placing credentials in the Nix store.
            '';
          };

          IDRAC_PASSWORD = lib.mkOption {
            type = with lib.types; nullOr str;
            default = null;
            description = ''
              iDRAC password for network mode (`IDRAC_HOST != "local"`).
              Warning: values set here are stored in the world-readable Nix
              store; use
              {option}`services.dell-idrac-fan-controller.environmentFile`
              instead.
            '';
          };

          FAN_SPEED = lib.mkOption {
            type = with lib.types; either (ints.between 0 100) (strMatching "^0[xX][0-9A-Fa-f]{1,2}$");
            default = 5;
            example = 15;
            description = ''
              Target fan duty cycle while the user profile is active, either as
              a decimal integer from `0` to `100` or a hexadecimal string from
              `"0x00"` to `"0x64"`.
            '';
          };

          CPU_TEMPERATURE_THRESHOLD = lib.mkOption {
            type = with lib.types; either (ints.between 20 125) (enum [ "auto" ]);
            default = "auto";
            example = 65;
            description = ''
              CPU temperature threshold (in degrees Celsius, `20` to `125`)
              above which Dell's default dynamic fan control profile is
              restored, or `"auto"` to read the CPU's `high` temperature from
              `lm-sensors` (falling back to `50` when unavailable).
            '';
          };

          HIGH_FAN_SPEED = lib.mkOption {
            type = with lib.types; nullOr (either (ints.between 0 100) (strMatching "^0[xX][0-9A-Fa-f]{1,2}$"));
            default = null;
            example = 50;
            description = ''
              When non-null, enables linear fan speed interpolation between
              `FAN_SPEED` and `HIGH_FAN_SPEED` as the hottest CPU rises from
              `CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION` toward
              `CPU_TEMPERATURE_THRESHOLD`. Must be greater than `FAN_SPEED`.
            '';
          };

          CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION = lib.mkOption {
            type = lib.types.ints.between 20 125;
            default = 30;
            description = ''
              CPU temperature (in degrees Celsius, `20` to `125`) at which
              linear fan speed interpolation starts climbing above `FAN_SPEED`.
              Only used when `HIGH_FAN_SPEED` is set; must be lower than
              `CPU_TEMPERATURE_THRESHOLD`.
            '';
          };

          CPU_TEMPERATURE_SOURCE = lib.mkOption {
            type = lib.types.enum [
              "auto"
              "ipmi"
              "lm-sensors"
            ];
            default = "auto";
            description = ''
              Source used to read CPU temperatures (`"auto"`, `"ipmi"`, or
              `"lm-sensors"`).
            '';
          };

          CHECK_INTERVAL = lib.mkOption {
            type = with lib.types; either ints.positive str;
            default = 5;
            example = "30s";
            description = ''
              Interval between temperature checks, in seconds or as a duration
              with an `s`, `m`, `h`, or `d` suffix (up to `15m` outside
              `MONITORING_ONLY_MODE`).
            '';
          };

          MAXIMUM_IPMI_UNREACHABLE_DURATION = lib.mkOption {
            type = with lib.types; nullOr (either ints.positive str);
            default = "60s";
            description = ''
              How long the iDRAC may stay unreachable before the controller
              exits so systemd can restart it with a fresh IPMI session. Set to
              `null` (or `""`) to retry forever.
            '';
          };

          MAXIMUM_CONSECUTIVE_IPMI_FAILURES = lib.mkOption {
            type = with lib.types; nullOr lib.types.ints.positive;
            default = null;
            example = 12;
            description = ''
              Alternative to `MAXIMUM_IPMI_UNREACHABLE_DURATION` expressed as a
              number of consecutive unreachable cycles (`>= 1`). Overrides
              `MAXIMUM_IPMI_UNREACHABLE_DURATION` when set.
            '';
          };

          DISABLE_THIRD_PARTY_PCIE_CARD_DELL_DEFAULT_COOLING_RESPONSE = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Whether to disable Dell's default cooling response for third-party
              PCIe cards (via IPMI or Redfish depending on server generation).
            '';
          };

          KEEP_THIRD_PARTY_PCIE_CARD_COOLING_RESPONSE_STATE_ON_EXIT = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Whether to keep the third-party PCIe card cooling response state
              when stopping the service instead of restoring Dell's default.
            '';
          };

          MONITORING_ONLY_MODE = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              When enabled, read and log temperatures without applying any fan
              control profile or changing PCIe cooling response settings.
            '';
          };
        };
      };
      default = { };
      description = ''
        Environment variables passed to `dell-idrac-fan-controller`.

        See <https://github.com/tigerblue77/Dell_iDRAC_fan_controller_Docker#parameters>
        for full parameter documentation.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          cfg.settings.IDRAC_HOST != "local" && cfg.environmentFile == null
          -> (cfg.settings.IDRAC_USERNAME or null) != null && (cfg.settings.IDRAC_PASSWORD or null) != null;
        message = ''
          services.dell-idrac-fan-controller: IDRAC_USERNAME and IDRAC_PASSWORD
          must be set (via settings or environmentFile) when IDRAC_HOST is not
          "local".
        '';
      }
      {
        assertion =
          cfg.settings.HIGH_FAN_SPEED != null && cfg.settings.CPU_TEMPERATURE_THRESHOLD != "auto"
          ->
            cfg.settings.CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION
            < cfg.settings.CPU_TEMPERATURE_THRESHOLD;
        message = ''
          services.dell-idrac-fan-controller.settings:
          CPU_TEMPERATURE_THRESHOLD_TO_START_LINE_INTERPOLATION must be lower
          than CPU_TEMPERATURE_THRESHOLD.
        '';
      }
    ];

    environment.systemPackages = [ cfg.package ];

    systemd.services.dell-idrac-fan-controller = {
      description = "Dell iDRAC fan controller";
      after = lib.optionals isNetworkMode [ "network-online.target" ];
      wants = lib.optionals isNetworkMode [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      environment = envSettings;

      serviceConfig = {
        ExecStart = lib.getExe cfg.package;
        EnvironmentFile = lib.optional (cfg.environmentFile != null) cfg.environmentFile;
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "5s";
        # Forward SIGTERM only to supervisor.sh so it can coordinate graceful
        # fan control hand-back before killing the monitoring child.
        KillMode = "mixed";
        TimeoutStopSec = "30s";

        RuntimeDirectory = "dell-idrac-fan-controller";

        # Hardening (runs as root so local /dev/ipmi0 and /sys/class/dmi/id/*_serial remain readable)
        CapabilityBoundingSet = "";
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        NoNewPrivileges = true;
        PrivateDevices = isNetworkOnly;
        PrivateTmp = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
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
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
        ];
        UMask = "0077";
      };
    };
  };
}
