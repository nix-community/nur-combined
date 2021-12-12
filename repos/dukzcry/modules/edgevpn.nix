{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.networking.edgevpn;
in {
  options.networking.edgevpn = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable EdgeVPN.
      '';
    };
    config = mkOption {
      type = types.str;
      default = "/etc/edgevpn/config.yaml";
    };
    interface = mkOption {
      type = types.str;
      default = "edgevpn0";
    };
    address = mkOption {
      type = types.str;
      default = "10.0.0.1/24";
    };
    apiPort = mkOption {
      type = types.ints.positive;
      default = 8080;
    };
    apiAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs.nur.repos.dukzcry; [ edgevpn ];

    systemd.services.edgevpn = {
      requires = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "EdgeVPN service";
      path = with pkgs; [ ];
      serviceConfig = {
        ExecStart = with pkgs.nur.repos.dukzcry; ''
          ${edgevpn}/bin/edgevpn --address ${cfg.address} --config ${cfg.config}
        '';
      };
      postStart = ''
      '';
      preStop = ''
      '';
    };

    systemd.services.edgevpn-web = {
      requires = [ "network-online.target" ];
      after = [ "network.target" "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      description = "EdgeVPN web service";
      path = with pkgs; [ ];
      serviceConfig = {
        ExecStart = with pkgs.nur.repos.dukzcry; ''
          ${edgevpn}/bin/edgevpn api --listen "${cfg.apiAddress}:${toString cfg.apiPort}" --config ${cfg.config}
        '';
      };
      postStart = ''
      '';
      preStop = ''
      '';
    };
  };
}
