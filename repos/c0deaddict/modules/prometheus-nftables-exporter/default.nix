{ config, lib, pkgs, options, ... }:

with lib;

let

  cfg = config.services.prometheus.nftables-exporter;

  format = pkgs.formats.json { };
  configFile = format.generate "config.json" { nftables_exporter = cfg.settings; };

in

{

  options.services.prometheus.nftables-exporter = {
    enable = mkEnableOption "the prometheus nftables exporter";

    package = mkOption {
      type = types.package;
      default = pkgs.nftables-exporter;
    };

    settings = mkOption {
      default = { };
      type = format.type;
    };
  };

  config = mkIf cfg.enable {
    services.prometheus.nftables-exporter.settings = {
      bind_to = lib.mkDefault "[::1]:9630";
      url_path = lib.mkDefault "/metrics";
      nft_location = lib.mkDefault "${pkgs.nftables}/bin/nft";
      log_level = lib.mkDefault "warn";
    };

    systemd.services."prometheus-nftables-exporter" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = "/tmp";
        DynamicUser = true;
        ExecStart = "${cfg.package}/bin/nftables-exporter --config ${configFile}";
      };
    };
  };
}
