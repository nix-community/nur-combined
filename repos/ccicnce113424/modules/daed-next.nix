{
  config,
  pkgs,
  lib,
  utils,
  ...
}:

let
  inherit (lib)
    literalExpression
    mkEnableOption
    mkOption
    mkPackageOption
    types
    ;

  cfg = config.services.daed-next;

  inherit (cfg) assets;

  genAssetsDrv =
    paths:
    pkgs.symlinkJoin {
      name = "daed-next-assets";
      inherit paths;
    };

  bin = lib.getExe cfg.package;

  # The daemon defaults its state database to <configDir>/daed.db.
  stateDb = "${cfg.stateDir}/daed.db";

  # The port to open in the firewall, taken from `listen`.
  listenPort = lib.toInt (lib.last (lib.splitString ":" cfg.listen));
in
{
  options.services.daed-next = {
    enable = mkEnableOption "daed-next, the Rust-native dae daemon and its web dashboard" // {
      description = ''
        Starts the daemon and its web dashboard. Only one of
        {option}`services.daed-next`, {option}`services.daed` and
        {option}`services.dae` can be enabled at a time: they share the same
        eBPF datapath, the transparent proxy port and the dashboard port.
      '';
    };

    package = mkPackageOption pkgs "daed-next-git" { };

    configDir = mkOption {
      type = types.str;
      default = "/etc/daed";
      description = ''
        Directory holding daed's configuration and the files its web UI edits.
        The daemon requires it to be writable.
      '';
    };

    stateDir = mkOption {
      type = types.str;
      default = "/var/lib/daed";
      description = ''
        Directory holding daed's SQLite state database, its logs and the
        geodata files it maintains.
      '';
    };

    listen = mkOption {
      type = types.str;
      default = "127.0.0.1:2023";
      example = "0.0.0.0:2023";
      description = ''
        Address the dashboard and its API listen on. The default keeps them on
        loopback; exposing them needs {option}`services.daed-next.openFirewall`.
      '';
    };

    assets = mkOption {
      type = with types; listOf path;
      default = with pkgs; [
        v2ray-geoip
        v2ray-domain-list-community
      ];
      defaultText = literalExpression "with pkgs; [ v2ray-geoip v2ray-domain-list-community ]";
      description = ''
        Assets seeded into {option}`services.daed-next.stateDir` as the geosite
        and geoip databases the routing rules resolve against.
      '';
    };

    assetsPath = mkOption {
      type = types.path;
      default = "${genAssetsDrv assets}/share/v2ray";
      defaultText = literalExpression ''
        "''${pkgs.symlinkJoin {
          name = "daed-next-assets";
          paths = config.services.daed-next.assets;
        }}/share/v2ray"
      '';
      description = ''
        The path which contains the geolocation databases.
        This option will override `assets`.
      '';
    };

    openFirewall = mkEnableOption "opening the dashboard and API port (taken from `listen`) in the firewall";

    extraArgs = mkOption {
      type = with types; listOf str;
      default = [ ];
      example = literalExpression ''[ "--api-only" ]'';
      description = "Extra arguments appended to the `daed run` command line.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];

    networking.firewall.allowedTCPPorts = lib.optional cfg.openFirewall listenPort;

    systemd.tmpfiles.rules = [
      "d ${cfg.configDir} 0700 root root - -"
      "d ${cfg.stateDir} 0700 root root - -"
      "d ${cfg.stateDir}/logs 0700 root root - -"
      # Seeded from the store unless the daemon already updated them in place.
      "C ${cfg.stateDir}/geoip.dat 0644 root root - ${cfg.assetsPath}/geoip.dat"
      "C ${cfg.stateDir}/geosite.dat 0644 root root - ${cfg.assetsPath}/geosite.dat"
    ];

    # The upstream unit is installed into the package as daed-next.service; its
    # Exec* lines and environment are overlaid as a drop-in below.
    systemd.packages = [ cfg.package ];

    systemd.services.daed-next = {
      wantedBy = [ "multi-user.target" ];

      # The three dae/daed flavours claim the same eBPF datapath and ports.
      conflicts = [
        "dae.service"
        "daed.service"
      ];

      # daed drives the datapath through ip/sysctl/tc and collects diagnostics
      # with bpftool.
      path = with pkgs; [
        bpftools
        coreutils
        iproute2
        procps
      ];

      serviceConfig = {
        # An empty assignment clears the unit's upstream /usr/bin entries before
        # the NixOS ones are appended.
        ExecStartPre = [
          ""
          (utils.escapeSystemdExecArgs [
            bin
            "validate"
            "-c"
            cfg.configDir
            "--state"
            stateDb
          ])
        ];
        ExecStart = [
          ""
          (utils.escapeSystemdExecArgs (
            [
              bin
              "run"
              "-c"
              cfg.configDir
              "--state"
              stateDb
              "--listen"
              cfg.listen
            ]
            ++ cfg.extraArgs
          ))
        ];
        ExecStartPost = [
          ""
          (utils.escapeSystemdExecArgs [
            bin
            "wait-ready"
            "--timeout"
            "60s"
          ])
        ];
        ExecReload = [
          ""
          (utils.escapeSystemdExecArgs [
            bin
            "reload"
            "--timeout"
            "60s"
          ])
        ];
        Environment = [
          "DAE_LOCATION_ASSET=${cfg.stateDir}"
          "DAED_PRODUCT_LOG_DIR=${cfg.stateDir}/logs"
          "PRODUCT_WEB_ROOT=${cfg.package}/share/daed/web"
        ];
      };
    };
  };

  meta.maintainers = with lib.maintainers; [ ccicnce113424 ];
}
