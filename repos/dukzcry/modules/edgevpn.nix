{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.networking.edgevpn;
  server = cfg.enable && cfg.server;
  client = cfg.enable && !cfg.server;
  edgevpn = pkgs.nur.repos.dukzcry.edgevpn;
in {
  options.networking.edgevpn = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to enable EdgeVPN.
      '';
    };
    server = mkEnableOption ''
      server mode
    '';
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
    router = mkOption {
      type = types.str;
      default = "";
    };
    apiPort = mkOption {
      type = types.ints.positive;
      default = 8080;
    };
    apiAddress = mkOption {
      type = types.str;
      default = "0.0.0.0";
    };
    postStart = mkOption {
      type = types.str;
      default = "";
      example = ''
        ip route add dev ${config.networking.edgevpn.interface} 10.0.0.0/24
        echo -e "nameserver 10.0.0.2\nsearch local" | resolvconf -a ${config.networking.edgevpn.interface}
      '';
    };
    preStop = mkOption {
      type = types.str;
      default = "";
      example = ''
        resolvconf -d ${config.networking.edgevpn.interface}
      '';
    };
  };

  config = mkMerge [
    (mkIf cfg.enable {
      environment.systemPackages = [ edgevpn ];
    })
    (mkIf server {
      systemd.services.edgevpn = {
        requires = [ "network-online.target" ];
        after = [ "network.target" "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        description = "EdgeVPN service";
        path = with pkgs; [ edgevpn iproute2 ];
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "edgevpn" ''
            edgevpn --address ${cfg.address} --config ${cfg.config} --api --api-listen "${cfg.apiAddress}:${toString cfg.apiPort}"
          '';
        };
        postStart = ''
          set +e
          ${optionalString (cfg.postStart != "") "sleep 5"}
          ${cfg.postStart}
          true
        '';
        preStop = ''
          set +e
          ${cfg.preStop}
          true
        '';
       };
    })
    (mkIf client {
      boot.kernel.sysctl."net.core.rmem_max" = mkDefault 2500000;
      systemd.services.edgevpn = {
        requires = [ "network-online.target" ];
        after = [ "network.target" "network-online.target" ];
        description = "EdgeVPN service";
        path = with pkgs; [ edgevpn iproute2 openresolv ];
        serviceConfig = {
          ExecStart = pkgs.writeShellScript "edgevpn" ''
            edgevpn --address ${cfg.address} --config ${cfg.config} ${optionalString (cfg.router != "") "--router ${cfg.router}"}
          '';
        };
        postStart = ''
          set +e
          ${optionalString (cfg.postStart != "") "sleep 5"}
          ${cfg.postStart}
          true
        '';
        preStop = ''
          set +e
          ${cfg.preStop}
          true
        '';
      };
    })
  ];
}
