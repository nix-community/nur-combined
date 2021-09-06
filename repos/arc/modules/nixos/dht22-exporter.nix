{ config, lib, pkgs, ... }: with lib; let
  cfg = config.services.dht22-exporter;
in {
  options.services.dht22-exporter = {
    enable = mkEnableOption "DHT22 Prometheus Exporter";
    platform = mkOption {
      description = "The board you are going to run the exporter on";
      default = null;
      type = with types; nullOr (enum [
        "pi"
        "pi2"
        "bbb"
      ]);
    };
    package = mkOption {
      type = types.package;
      default = with pkgs.python3Packages; dht22-exporter.override {
        adafruit-dht = adafruit-dht.override { inherit (cfg) platform; };
      };
    };
    address = mkOption {
      description = "The address Prometheus ingests from";
      type = types.nullOr types.str;
      default = null;
    };
    port = mkOption {
      description = "The port Prometheus ingests from";
      type = types.nullOr types.port;
      default = null;
    };
    gpio = mkOption {
      description = "The GPIO pin of your board";
      type = types.int;
      default = 4;
    };
    pollingRate = mkOption {
      description = "How often in seconds to poll the sensor?";
      type = types.int;
      default = 2;
    };
    user = mkOption {
      type = types.str;
      default = "root";
    };
    group = mkOption {
      type = types.str;
      default = "root";
    };
  };
  config = mkIf cfg.enable {
    systemd.services.dht22-exporter = {
      wantedBy = singleton "multi-user.target";
      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        ExecStart = let
          args = [
            "-g" (toString cfg.gpio)
            "-i" (toString cfg.pollingRate)
          ] ++ optionals (cfg.port != null) [ "-p" (toString cfg.port) ]
          ++ optionals (cfg.address != null) [ "-a" cfg.address ];
        in "${cfg.package}/bin/dht22_exporter.py " + escapeShellArgs args;
      };
    };
  };
}
