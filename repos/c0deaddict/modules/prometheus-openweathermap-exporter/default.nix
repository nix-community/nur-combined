{ config, lib, pkgs, options, ... }:

with lib;

let

  cfg = config.services.prometheus.openweathermap-exporter;

in {

  options.services.prometheus.openweathermap-exporter = {
    enable = mkEnableOption "the prometheus openweathermap exporter";

    package = mkOption {
      type = types.package;
      default = pkgs.my-nur.prometheus-openweathermap-exporter;
    };

    port = mkOption {
      type = types.int;
      default = 9099;
      description = ''
        Port to listen on.
      '';
    };
    listenAddress = mkOption {
      type = types.str;
      default = "127.0.0.1";
      description = ''
        Address to listen on.
      '';
    };
    city = mkOption {
      type = types.listOf types.str;
      default = [ "Groningen, NL" ];
      description = ''
        City/Location in which to gather weather metrics.
      '';
    };
    degreesUnit = mkOption {
      type = types.enum [ "K" "F" "C" ];
      default = "C";
      description = ''
        Unit in which to show metrics (Kelvin, Fahrenheit or Celsius).
      '';
    };
    apiKeyPath = mkOption {
      type = types.str;
      description = ''
        Path to file containing the OpenWeatherMap API key.
      '';
    };
    extraFlags = mkOption {
      type = types.listOf types.str;
      default = [ ];
      description = ''
        Extra command line flags to pass to the exporter. See:
        <link>https://github.com/billykwooten/openweather-exporter#usage</link>
      '';
    };
  };

  config = mkIf cfg.enable {
    # TODO: hardening
    # https://github.com/NixOS/nixpkgs/blob/98b4daa99479669058c9322cd02705d404a2def6/nixos/modules/services/monitoring/prometheus/exporters.nix#L182
    systemd.services."prometheus-openweathermap-exporter" = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        Restart = "always";
        PrivateTmp = true;
        WorkingDirectory = /tmp;
        DynamicUser = true;
        LoadCredential = [ "apikey:${cfg.apiKeyPath}" ];
        ExecStart = pkgs.writers.writeDash "start" ''
          export OW_APIKEY=$(cat $CREDENTIALS_DIRECTORY/apikey)
          ${cfg.package}/bin/prometheus-openweathermap-exporter \
            --listen-address "${cfg.listenAddress}:${toString cfg.port}" \
            --city '${concatStringsSep "|" cfg.city}' \
            --degrees-unit ${cfg.degreesUnit} \
            ${concatStringsSep " \\\n  " cfg.extraFlags}
        '';
      };
    };
  };
}
