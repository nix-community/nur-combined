{ config, pkgs, lib, ... }:
let
  xraya = pkgs.callPackage ./default.nix { };
in {
  options = {
    services.xraya = {
      enable = lib.options.mkEnableOption "the v2rayA service";
    };
  };

  config = lib.mkIf config.services.xraya.enable {
    systemd.services.xraya = {
      unitConfig = {
        Description = "xrayA service";
        Documentation = "https://github.com/v2rayA/v2rayA/wiki";
        After = [ "network.target" "nss-lookup.target" "iptables.service" "ip6tables.service" ];
        Wants = [ "network.target" ];
      };

      serviceConfig = {
        User = "root";
        ExecStart = "${xraya}/bin/xraya";
        LimitNPROC = 500;
        LimitNOFILE = 1000000;
        Environment = "V2RAYA_LOG_FILE=/var/log/xraya/xraya.log";
        Restart = "on-failure";
        Type = "simple";
      };

      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ iptables bash iproute2 ]; # required by xrayA TProxy functionality
    };
  };
}

