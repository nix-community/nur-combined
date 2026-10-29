{ pkgs, ... }:
let
  port = 4242;
  stateDir = "/var/lib/lxmd";
  rnsConfig = pkgs.writeText "rns-config" ''
    [reticulum]
    enable_transport = Yes
    share_instance = Yes
    panic_on_interface_error = No

    [logging]
    loglevel = 4

    [interfaces]
    [[Default Interface]]
    type = AutoInterface
    enabled = No

    [[TCP Server]]
    type = TCPServerInterface
    enabled = Yes
    listen_ip = 0.0.0.0
    listen_port = ${toString port}

    [[Beleth RNS Hub]]
    type = TCPClientInterface
    enabled = Yes
    target_host = rns.beleth.net
    target_port = 4242

    [[g00n.cloud Hub]]
    type = TCPClientInterface
    enabled = Yes
    target_host = dfw.us.g00n.cloud
    target_port = 6969

    [[StoppedCold]]
    type = TCPClientInterface
    enabled = Yes
    target_host = rns.stoppedcold.com
    target_port = 4242
  '';
  lxmdConfig = pkgs.writeText "lxmd-config" ''
    [propagation]
    enable_node = yes
    node_name = prophecy
    announce_interval = 360
    announce_at_start = yes
    autopeer = yes
    autopeer_maxdepth = 6
    message_storage_limit = 2000

    [lxmf]
    display_name = prophecy
    announce_at_start = no

    [logging]
    loglevel = 4
  '';
in
{
  systemd.services.lxmd = {
    description = "LXMF propagation node";
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    environment.PYTHONUNBUFFERED = "1";
    preStart = ''
      mkdir -p ${stateDir}/rns
      ln -sfn ${rnsConfig} ${stateDir}/rns/config
      ln -sfn ${lxmdConfig} ${stateDir}/config
    '';
    serviceConfig = {
      ExecStart = "${pkgs.python3Packages.lxmf}/bin/lxmd --config ${stateDir} --rnsconfig ${stateDir}/rns";
      DynamicUser = true;
      StateDirectory = "lxmd";
      Restart = "on-failure";
      RestartSec = 10;
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
    };
  };

  networking.firewall.allowedTCPPorts = [ port ];
}
