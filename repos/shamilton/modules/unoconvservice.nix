{ tfk-api-unoconv, unoconv, simplehaproxy }:
{ config, lib, pkgs, specialArgs, options, modulesPath }:
let
  cfg = config.services.unoconvservice;
  hostAddress = "192.168.100.10";
  containerAddress = "192.168.100.11";
  supportedFormats = import ./unoconvformats.nix;
  regexFormats = "(" + builtins.concatStringsSep "$|" supportedFormats +"$)";
in
with lib; {
  imports = [ simplehaproxy ];
  options.services.unoconvservice = {
    enable = mkEnableOption "Smart fan control for the the RPi Poe Hat";
    port = mkOption {
      type = types.port;
      default = 80;
      description = "Port for unoconv to listen";
    };
    timeout = mkOption {
      type = types.ints.unsigned;
      default = 500;
      description = ''
        Number of seconds to wait before closing the connection.
        Increase if you send files that are long to convert and if you get 
        error: 504 Gateway Time-out.
      '';
    };
    timeoutStartSec = mkOption {
      type = types.str;
      default = "1min";
      description = ''
        Time for the container to start. In case of a timeout,
        the container processes get killed.
        See <citerefentry><refentrytitle>systemd.time</refentrytitle>
        <manvolnum>7</manvolnum></citerefentry>
        for more information about the format.
      '';
    };
  };
  config = mkIf cfg.enable {
    services.simplehaproxy = {
      enable = true;
      proxies.unoconvservice = {
        listenPort = cfg.port;
        backendPort = cfg.port;
        backendAddress = containerAddress;
      };
    };
    containers.unoconvserver = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = hostAddress;
      localAddress = containerAddress;
      timeoutStartSec = cfg.timeoutStartSec;
      config =
        { config, pkgs, ... }:
        {
          imports = [
            # unoconv
            tfk-api-unoconv
          ];
          services.journald.extraConfig = ''
            SystemMaxUse=20M
          '';
          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ cfg.port 3000 ];
          };
          environment.systemPackages = [
            pkgs.unoconv
          ];
          services.tfk-api-unoconv = {
            enable = true;
            port = 3000;
          };
          services.nginx = traceValFn (x: "regexFormats: ${regexFormats}") {
            enable = true;
            logError = "stderr debug";
            recommendedOptimisation = true;
            recommendedProxySettings = true;
            recommendedGzipSettings = true;
            appendHttpConfig = ''
              limit_conn_zone $binary_remote_addr zone=addr:10m;
            '';
            virtualHosts."unoconv.webservice" = {
              listen = [{
                addr = "*";
                port = cfg.port;
              }];
              locations."/favicon.ico" = {
                return = "204";
              };
              locations."/robots.txt" = {
                extraConfig = "default_type text/plain;";
                return = "200 'User-agent: *\nDisallow: /\n'";
              };
              locations."~ \"/unoconv/${regexFormats}\"" = {
                proxyPass = "http://0.0.0.0:3000/unoconv/$1";
                # Protect from slow loris, 2 connections per IP max
                extraConfig = ''
                  limit_conn addr 2;
                  proxy_connect_timeout ${toString cfg.timeout}s;
                  proxy_send_timeout    ${toString cfg.timeout}s;
                  proxy_read_timeout    ${toString cfg.timeout}s;
                  send_timeout          ${toString cfg.timeout}s;
                '';
              };
              locations."/unoconv/versions" = {
                proxyPass = "http://0.0.0.0:3000/unoconv/versions";
                # Protect from slow loris, 2 connections per IP max
                extraConfig = "limit_conn addr 2;";
              };
              locations."/unoconv/formats" = {
                proxyPass = "http://0.0.0.0:3000/unoconv/formats";
                # Protect from slow loris, 2 connections per IP max
                extraConfig = "limit_conn addr 2;";
              };
            };
          };
        };
    };
  };
}
