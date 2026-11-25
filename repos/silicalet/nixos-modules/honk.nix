{
  config,
  lib,
  pkgs,
  utils,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  cfg = config.services.honk-proxy;
  selectedPackage =
    if cfg.package ? withDoona && cfg.package.withDoona != cfg.doona then
      cfg.package.override { withDoona = cfg.doona; }
    else
      cfg.package;
  geoAssets = pkgs.symlinkJoin {
    name = "honk-v2ray-assets";
    paths = cfg.assets;
  };
  configPath = if cfg.configDir != null then "${cfg.configDir}/config.dae" else cfg.configFile;
  modules = [
    "nfnetlink_queue"
    "nft_ct"
    "nft_queue"
  ];
in
{
  options.services.honk-proxy = {
    enable = mkEnableOption "honk eBPF transparent proxy";
    doona = mkOption {
      type = types.bool;
      default = true;
      description = "Use a Honk build with the embedded Doona UI.";
    };
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ../pkgs/tools/honk/binary.nix { withDoona = cfg.doona; };
      defaultText = lib.literalExpression "honk-bin";
      description = "Honk package providing bin/honk-core. Both repository packages support the doona switch.";
    };
    configFile = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/etc/honk/config.dae";
      description = "Absolute path to a dae configuration file. May be a symlink.";
    };
    configDir = mkOption {
      type = types.nullOr types.str;
      default = null;
      example = "/etc/honk";
      description = "Absolute runtime directory containing config.dae and config.d/ include fragments.";
    };
    assets = mkOption {
      type = types.listOf types.path;
      default = [
        pkgs.v2ray-geoip
        pkgs.v2ray-domain-list-community
      ];
      defaultText = lib.literalExpression "with pkgs; [ v2ray-geoip v2ray-domain-list-community ]";
      description = "Packages providing GeoIP and GeoSite databases under share/v2ray.";
    };
    assetsPath = mkOption {
      type = types.path;
      default = "${geoAssets}/share/v2ray";
      defaultText = "<v2ray-geoip + v2ray-domain-list-community>/share/v2ray";
      description = "Directory containing geoip.dat and geosite.dat.";
    };
    loadNfqueueModules = mkEnableOption "attempting to load Honk NFQUEUE kernel modules before startup";
    openFirewall.enable = mkEnableOption "opening the configured transparent proxy port for TCP and UDP";
    openFirewall.port = mkOption {
      type = types.port;
      default = 12345;
      description = "Match global.tproxy_port in the Honk configuration. Not the Doona API port.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = (cfg.configFile != null) != (cfg.configDir != null);
        message = "services.honk-proxy requires exactly one of configFile or configDir.";
      }
      {
        assertion = cfg.configFile == null || lib.hasPrefix "/" cfg.configFile;
        message = "services.honk-proxy.configFile must be an absolute path.";
      }
      {
        assertion = cfg.configDir == null || lib.hasPrefix "/" cfg.configDir;
        message = "services.honk-proxy.configDir must be an absolute runtime directory.";
      }
    ];
    environment.systemPackages = [ selectedPackage ];
    networking.firewall = mkIf cfg.openFirewall.enable {
      allowedTCPPorts = [ cfg.openFirewall.port ];
      allowedUDPPorts = [ cfg.openFirewall.port ];
    };
    systemd.services.honk-core = {
      description = "honk transparent proxy engine";
      documentation = [ "https://github.com/daeuniverse/honk" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "systemd-sysctl.service"
      ];
      conflicts = [ "dae.service" ];
      serviceConfig = {
        Type = "notify";
        User = "root";
        StateDirectory = "honk";
        StateDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/honk";
        ExecStartPre = lib.optional cfg.loadNfqueueModules "-${pkgs.kmod}/bin/modprobe -a ${lib.concatStringsSep " " modules}";
        ExecStart = "${selectedPackage}/bin/honk-core --config ${
          utils.escapeSystemdExecArg (if configPath == null then "" else configPath)
        } --disable-timestamp";
        ExecReload = "${selectedPackage}/bin/honk-core reload";
        Restart = "on-failure";
        RestartSec = "2s";
        TimeoutStartSec = 120;
        TimeoutStopSec = 30;
        LimitNPROC = 4096;
        LimitNOFILE = 1048576;
        LimitMEMLOCK = "infinity";
        UMask = "0077";
      };
      environment.DAE_LOCATION_ASSET = toString cfg.assetsPath;
    };
  };
}
