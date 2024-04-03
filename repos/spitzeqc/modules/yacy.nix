{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.yacy;
  nur = import (builtins.fetchTarball "https://github.com/spitzeqc/nur-packages/archive/master.tar.gz") {};
in
{
  options = with types; {
    services.yacy = {
      enable = mkEnableOption (lib.mdDoc "YaCy system service");

      dataFolder = mkOption {
        type = str;
        default = "/var/yacy";
        example = "/home/user/.cache/yacy";
        description = lib.mdDoc ''
          Path for the DATA directory
        '';
      };

      package = mkPackageOption nur "yacy" { };
    };
  };

  config = mkIf cfg.enable (
    let
      binStartYacy = "${cfg.package}/bin/startYACY";
      binStopYacy = "${cfg.package}/bin/stopYACY";
    in
    {
      environment.systemPackages = [ cfg.package ];

      systemd.services.yacy = {
        description = "YaCy Web Crawler/Indexer & Search Engine";
        wantedBy = [ "multi-user.target" ];
        environment = { YACY_DATA_PATH = "${cfg.dataFolder}/DATA"; };
        serviceConfig = {
          Type = "forking";
          ExecStart = "${binStartYacy} -s ${cfg.dataFolder}";
          ExecStop = "${binStopYacy}";
          Restart = "on-failure";
        };
      };
    }
  );
  meta = {
    maintainers = with lib.maintainers; [ spitzeqc ];
  };
}
