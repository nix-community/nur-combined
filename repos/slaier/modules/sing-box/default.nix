{
  config,
  lib,
  pkgs,
  ...
}:
{
  services.sing-box.enable = true;
  systemd.services.sing-box.serviceConfig.ExecStartPre = lib.mkForce (
    let
      script = pkgs.writeShellScript "sing-box-pre-start" ''
        cp ${config.sops.secrets.sing-box.path} /run/sing-box/config.json
        chown --reference=/run/sing-box /run/sing-box/config.json
      '';
    in
    "+${script}"
  );
  sops.secrets.sing-box = {
    format = "json";
    key = "";
    sopsFile = ../../secrets/sing-box.json;
    restartUnits = [ "sing-box.service" ];
    owner = config.systemd.services.sing-box.serviceConfig.User;
  };
  programs.proxychains = {
    enable = true;
    package = pkgs.proxychains-ng;
    proxies = {
      sing-box = {
        enable = true;
        host = "127.0.0.1";
        port = 7890;
        type = "http";
      };
    };
    proxyDNS = false;
  };
}
