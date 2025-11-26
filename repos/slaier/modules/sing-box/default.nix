{ config, lib, pkgs, ... }:
let
  sing-box-config = pkgs.replaceVars ./config.json {
    yacd = pkgs.nur.repos.linyinfeng.yacd;
  };
in
{
  systemd.services.sing-box = {
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];
    description = "Enable sing-box services";
    serviceConfig = {
      Environment = [
        "ENABLE_DEPRECATED_GEOIP=true"
        "ENABLE_DEPRECATED_GEOSITE=true"
      ];
      RuntimeDirectory = "sing-box";
      StateDirectory = "sing-box";
      Type = "simple";
      ExecStart = "${lib.getExe' pkgs.sing-box "sing-box"} run -c ${sing-box-config} -c ${config.sops.secrets.sing-box.path} -D $STATE_DIRECTORY --disable-color";
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
