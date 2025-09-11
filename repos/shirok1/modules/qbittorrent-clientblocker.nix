{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.qbittorrent-clientblocker;
  myLib = import ../lib { inherit pkgs; };
  settingsFormat = pkgs.formats.json { };
  defaultConfig = myLib.fromJSON5File "${cfg.package}/share/doc/${cfg.package.pname}/config.example.json";
  sharePrefix = "${cfg.package}/share/${cfg.package.pname}";
  shareConfig =
    defaultConfig
    // (lib.genAttrs [ "blockListFile" "ipBlockListFile" ] (
      k: (map (x: "${sharePrefix}/${x}")) defaultConfig.${k}
    ));
  finalConfig = lib.recursiveUpdate shareConfig cfg.settings;
in
{
  options.services.qbittorrent-clientblocker = {
    enable = lib.mkEnableOption "Enable qBittorrent Client Blocker";

    settings = lib.mkOption {
      type = settingsFormat.type;
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
        ExecStart = "${lib.getExe cfg.package} --nochdir --config ${settingsFormat.generate "qbittorrent-clientblocker.json" finalConfig}";
        StateDirectory = "qbittorrent-clientblocker";
        WorkingDirectory = "/var/lib/${StateDirectory}";
        Restart = "on-failure";
        DynamicUser = true;
      };
    };

    environment = {
      systemPackages = [ cfg.package ];
    };
  };
}
