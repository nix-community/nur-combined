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
    optionals
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
      description = "Packages providing GeoIP and GeoSite databases under share/v2ray. Their files are linked into /var/share/honk as a fallback.";
    };
    assetsPath = mkOption {
      type = types.nullOr types.path;
      default = if cfg.assets == [ ] then null else "${geoAssets}/share/v2ray";
      defaultText = "<v2ray-geoip + v2ray-domain-list-community>/share/v2ray";
      description = ''
        Directory containing geoip.dat and geosite.dat. Its files are linked
        into /var/share/honk, which Honk searches after global.data_dir, so
        files downloaded or provided there take precedence. Set to null to
        disable the links.
      '';
    };
    loadNfqueueModules = mkOption {
      type = types.bool;
      default = true;
      description = ''
        Load the NFQUEUE kernel modules before startup, matching the AUR
        package. Without nfnetlink_queue Honk disables NFQUEUE until the next
        restart.
      '';
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
    systemd.tmpfiles.rules = optionals (cfg.assetsPath != null) [
      "d /var/share/honk 0755 root root -"
      "L+ /var/share/honk/geoip.dat - - - - ${cfg.assetsPath}/geoip.dat"
      "L+ /var/share/honk/geosite.dat - - - - ${cfg.assetsPath}/geosite.dat"
    ];
    systemd.services.honk-core = {
      description = "honk transparent proxy engine";
      documentation = [ "https://github.com/daeuniverse/honk" ];
      wantedBy = [ "multi-user.target" ];
      wants = [ "network-online.target" ];
      after = [
        "network-online.target"
        "systemd-sysctl.service"
        "docker.service"
      ];
      conflicts = [ "dae.service" ];
      startLimitIntervalSec = 300;
      startLimitBurst = 5;
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
        OOMScoreAdjust = -100;
        UMask = "0077";
      };
    };
  };
}
