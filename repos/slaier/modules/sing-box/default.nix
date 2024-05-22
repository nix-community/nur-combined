{ config, lib, pkgs, ... }:
let
  sing-box-config = with pkgs; substituteAll {
    src = ./config.json;
    geoip = "${sing-geoip}/share/sing-box/geoip.db";
    geosite = "${sing-geosite}/share/sing-box/geosite.db";
    yacd = config.nur.repos.linyinfeng.yacd;
  };
in
{
  nixpkgs.overlays = [
    (final: prev: {
      sing-box = prev.sing-box.override {
        buildGoModule = old: final.buildGoModule (old // rec {
          version = "1.8.13";
          src = final.fetchFromGitHub {
            owner = "SagerNet";
            repo = old.pname;
            rev = "v${version}";
            hash = "sha256-BFkf+Gdej/AsIL89obHEwchrw4IcZqjEkr/suYKbVKY=";
          };
          vendorHash = "sha256-8OsUAknSuSJH1rRxMf8EVTUuIDHsIJauVI7hB4Fk1KU=";
        });
      };
    })
  ];
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
