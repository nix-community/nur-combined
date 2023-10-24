{ config, lib, pkgs, ... }:

let
  frpcConfigFile = pkgs.writeText "frps.ini"
  ''
    [common]
    server_addr = cosmic.ainative.eu
    server_port = 7000
    token = VopOstedjok1ddd1
    authentication_method = token

    [ssh]
    type = tcp
    local_ip = 127.0.0.1
    local_port = 22
    remote_port = 7001

    [test]
    type = http
    local_ip = 127.0.0.1
    local_port = 9090
    subdomain = test
  '';
in
{
  environment.systemPackages = with pkgs; [
    frp
  ];

  systemd.services.frpc = {
    enable = true;
    description = "vpn service";
    serviceConfig = {
      ExecStart = "/run/current-system/sw/bin/frpc -c ${frpcConfigFile}";
      Restart = "always";
      RestartSec=5;
      StartLimitBurst=99;
    };
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
  };
}

