{ lib, config, pkgs, ... }:

let cfg = config.services.consul;
in with lib;
{
  options.services.consul = with types; with builtins; {
    services = mkOption {
      default = [ ];
      type = listOf attrs;
      description = ''
        Service definitions
      '';
    };

    checks = mkOption {
      default = [ ];
      type = listOf attrs;
      description = ''
        Check definitions
      '';
    };

    advertise_addr_wan = mkOption {
      default = null;
      type = nullOr string;
      description = ''
        IP address to publish to federated nodes.
      '';
    };

    advertise_addr = mkOption {
      default = ''{{ GetInterfaceIP "eth0" }}'';
      type = string;
      description = ''
        IP address to publish to nodes in the same datacenter.
      '';
    };

    translate_wan_addrs = mkOption {
      default = true;
      type = bool;
      description = ''
        If set to true, Consul will prefer a node's configured WAN address when servicing DNS and HTTP requests for a node in a remote datacenter. This allows the node to be reached within its own datacenter using its local address, and reached from other datacenters using its WAN address, which is useful in hybrid setups with mixed networks. This is enabled by default.
      '';
    };

    datacenter = mkOption {
      default = "us-east-1";
      type = string;
    };

    server = mkOption {
      default = false;
      type = bool;
      description = ''
        Be a server.
      '';
    };

    ui = mkOption {
      default = false;
      type = bool;
      description = ''
        Serve web ui.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [ 8300 8301 8302 ];

    systemd.services.consul-alerts.serviceConfig.ExecStart = lib.mkIf cfg.alerts.enable (lib.mkForce ''
      ${cfg.alerts.package.bin}/bin/consul-alerts start \
        ${optionalString cfg.alerts.watchChecks "--watch-checks"} \
        ${optionalString cfg.alerts.watchEvents "--watch-events"} \
        --log-level=warn \
        --alert-addr=${cfg.alerts.listenAddr} \
        --consul-addr=${cfg.alerts.consulAddr} \
        --consul-dc=${cfg.datacenter} \
        --consul-acl-token=""
    '');

    services = {
      dnsmasq = {
        enable = true;
        extraConfig = "server=/consul/127.0.0.1#8600";
      };

      consul = {
        extraConfig = with builtins; mkMerge [{
          retry_join = ["provider=aws tag_key=consul:dc tag_value=${cfg.datacenter}"];
          acl_default_policy = "allow";
          enable_script_checks = true;
          log_level = "INFO";
          protocol = 3;
          inherit (cfg) services checks datacenter advertise_addr translate_wan_addrs server ui;
        } (optionalAttrs (cfg.advertise_addr_wan != null) {
          inherit (cfg) advertise_addr_wan;
        })];
      };
    };
  };
}
