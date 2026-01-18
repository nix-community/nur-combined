{ config, lib, pkgs, ... }:
let
  rule = path : "https://raw.githubusercontent.com/slaier/sing-rule-set/refs/tags/v20260118/" + path;
  sing-box-config = pkgs.replaceVars ./config.json {
    yacd = pkgs.nur.repos.linyinfeng.yacd;
    geosite-github = pkgs.fetchurl {
      url = rule "geo/geosite/part_8/github.json";
      hash = "sha256-RT8jQarD+ySWGyetX27t9VT+l9KggbTje+LcBKfbWGg=";
    };
    geosite-google = pkgs.fetchurl {
      url = rule "geo/geosite/part_8/google.json";
      hash = "sha256-sBJ30bGoO0TPkmGQ5ZrtXal9q567DKrGwPbahxzeUlI=";
    };
    geoip-cn = pkgs.fetchurl {
      url = rule "geo/geoip/part_1/cn.json";
      hash = "sha256-9GTPj+uo8ut+lNowNK0NI/2au/LUi8tP/s258Ygvwg0=";
    };
    geosite-cn = pkgs.fetchurl {
      url = rule "geo/geosite/part_5/cn.json";
      hash = "sha256-9/GGrVtBUTM51IzGkhSpNu0Fv+b0C1yzpa3ys6c6x9w=";
    };
    geosite-reddit = pkgs.fetchurl {
      url = rule "geo/geosite/part_14/reddit.json";
      hash = "sha256-wXZu+2Jp0LcladVR8L5TNq0JZJU/bikDg4FMgWhiIgQ=";
    };
    geosite-microsoft = pkgs.fetchurl {
      url = rule "geo/geosite/part_11/microsoft.json";
      hash = "sha256-C1Aax68vPqh3WoJAeEltEZ9vrYgaHjl+cLUVVHPC3I8=";
    };
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
