{ config, lib, networking, pkgs, ... }:

with lib;

let

  cfg = config.services.checkmk-agent;

in

{

  ###### interface

  options = {

    services.writefreely = rec {

      enable = mkOption {
        default = false;
        description = "Whether to enable the checkmk-agent.";
      };

      interval = mkOption {
        default = 60;
        description = "How often to loop for the async checks.";
      };

      bindIp = mkOption {
        default = "127.0.0.1:6556";
        description = "IP to bind the agent to. For security reasons defaults to 127.0.0.1:6556. Overwrite this and setup your firewall and the IPAddress*-Options.";
      };

      IPAddressAllow = mkOption {
        default = "10.0.0.0/8";
        description = "Allow access from these IPs. Sets systemd socket IPAddressAllow to this value.";
      };
      IPAddressDeny = mkOption {
        default = "any";
        description = "Deny access from these IPs. Sets systemd socket IPAddressDeny to this value.";
      };

      package = mkOption {
        default = pkgs.checkmk-agent;
        description = "Overwrite the agent package.";
      };

    };

  };

  ###### implementation

  config = mkIf config.services.checkmk-agent.enable {

    systemd.services."checkmk-agent-async" = {
      description = "CheckMK-Agent async background tasks";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        ExecStart = "${cfg.package}/bin/check_mk_agent";
        Type = "simple";
      };
      environment = {
        MK_RUN_SYNC_PARTS = "false";
        MK_LOOP_INTERVAL = toString cfg.interval;
      };
    };
    systemd.services."checkmk-agent@" = {
      description = "CheckMK-Agent";
      serviceConfig = {
        ExecStart = "-${cfg.package}/bin/check_mk_agent";
        Type = "simple";
        StandardInput = "socket";
      };
      environment = {
        MK_RUN_ASYNC_PARTS = "false";
        MK_READ_REMOTE = "true";
      };
    };
    systemd.sockets."checkmk-agent" = {
      listenStreams = [ cfg.bindIp ];
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        Accept = true;
        FreeBind = true;
        MaxConnectionsPerSource = 2;
        IPAddressDeny = cfg.IPAddressDeny;
        IPAddressAllow = cfg.IPAddressAllow;
      };
    };
  };

}
