{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.qbittorrent-clientblocker;
  myLib = import ../lib { inherit pkgs; };
  defaultConfig = myLib.fromJSON5File "${cfg.package}/share/doc/${cfg.package.pname}/config.example.json";
  sharePrefix = "${cfg.package}/share/${cfg.package.pname}";
  shareConfig =
    defaultConfig
    // (lib.genAttrs [ "blockListFile" "ipBlockListFile" ] (
      k: (map (x: "${sharePrefix}/${x}")) defaultConfig.${k}
    ));
  finalConfig = lib.recursiveUpdate shareConfig cfg.settings;
  configFile = pkgs.writeText "config.json" (builtins.toJSON finalConfig);
  # settingsFormat = pkgs.formats.json {};
  # configFile = pkgs.writeText "config.json" (builtins.toJSON cfg.settings);
  binPath = "${cfg.package}/bin/${cfg.package.meta.mainProgram}";
in
{
  options.services.qbittorrent-clientblocker = {
    enable = lib.mkEnableOption "Enable qBittorrent Client Blocker";

    settings = lib.mkOption {
      type = lib.types.submodule {
        # freeformType = lib.types.attrs; # or lib.types.attrsOf lib.types.anything
        # freeformType = settingsFormat.type;
        freeformType = lib.types.attrsOf lib.types.anything;
      };
      default = shareConfig;
      description = "JSON settings to write into the configuration file.";
      example = {
        checkUpdate = false;
        interval = 6;
        cleanInterval = 3600;
        banTime = 86400;
        timeout = 6;
        clientType = "qBittorrent";
        clientURL = "http://127.0.0.1:8080/api";
        clientUsername = "admin";
        clientPassword = "password";
        useBasicAuth = false;
        blockListFile = [
          "blockList.json"
        ];
        ipBlockListFile = [
          "ipBlockList.txt"
        ];
      };
    };

    package = lib.options.mkPackageOption pkgs "qbittorrent-clientblocker" { };
    # package = lib.mkOption {
    #   type = lib.types.package;
    #   default = pkgs.qbittorrent-clientblocker;
    #   description = "The qbittorrent-clientblocker package to use.";
    # };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.qbittorrent-clientblocker = {
      description = "qBittorrent Client Blocker";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];

      restartIfChanged = true;

      serviceConfig = rec {
        # ExecStart = "${binPath} --nochdir --config /etc/qbittorrent-clientblocker.json";
        ExecStart = "${binPath} --nochdir --config ${configFile}";
        StateDirectory = "qbittorrent-clientblocker";
        WorkingDirectory = "/var/lib/${StateDirectory}";
        Restart = "on-failure";
        # User = "nobody"; # or better: use DynamicUser=yes + CapabilityBoundingSet= if needed
      };
    };

    environment = {
      systemPackages = [ cfg.package ];
      # etc."qbittorrent-clientblocker.json".source = configFile;
    };
  };
}
