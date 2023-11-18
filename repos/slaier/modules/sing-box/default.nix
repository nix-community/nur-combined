{ config, lib, pkgs, ... }:
let
  sing-box-config = with pkgs; substituteAll {
    src = ./config.json;
    geoip = "${sing-geoip.overrideAttrs { preBuild = "export ASSUME_NO_MOVING_GC_UNSAFE_RISK_IT_WITH=go1.20"; }}/share/sing-box/geoip.db";
    geosite = "${pkgs.sing-geosite}/share/sing-box/geosite.db";
    yacd = config.nur.repos.linyinfeng.yacd;
  };
in
{
  systemd.services.sing-box = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "Enable sing-box services";
    serviceConfig = {
      RuntimeDirectory = "sing-box";
      StateDirectory = "sing-box";
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.sing-box} run -c ${sing-box-config} -c ${config.sops.secrets.sing-box.path} -D $STATE_DIRECTORY --disable-color";
    };
  };
  sops.secrets.sing-box = {
    format = "json";
    key = "";
    sopsFile = ../../secrets/sing-box.json;
    restartUnits = [ "sing-box.service" ];
  };
  networking.firewall.allowedTCPPorts = [
    7890 # http_proxy
    9090 # clashctl
  ];
}
