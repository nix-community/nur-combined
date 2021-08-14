{ tfk-api-unoconv, unoconv }:
{ config, lib, pkgs, specialArgs, options, modulesPath }:
let
  cfg = config.services.unoconvservice;
in
with lib; {
  options.services.unoconvservice = {
    enable = mkEnableOption "Smart fan control for the the RPi Poe Hat";
    port = mkOption {
      type = types.port;
      default = 80;
      description = "Port for unoconv to listen";
    };
  };
  config = mkIf cfg.enable {
    containers.unoconvserver = {
      autoStart = true;
      privateNetwork = true;
      hostAddress = "192.168.100.10";
      localAddress = "192.168.100.11";
      config =
        { config, pkgs, ... }:
        {
          imports = [
            # unoconv
            tfk-api-unoconv
          ];

          networking.firewall = {
            enable = true;
            allowedTCPPorts = [ 3000 ];
            allowedUDPPorts = [ 3000 ];
          };
          environment.systemPackages = [
            pkgs.unoconv
          ];
          # services.unoconv = {
          #   enable = true;
          #   port = 2002;
          # };
          services.tfk-api-unoconv.enable = true;
        };
    };
    services.nginx = {
      enable = true;
      logError = "stderr debug";
      recommendedOptimisation = true;
      recommendedProxySettings = true;
      recommendedGzipSettings = true;
      appendHttpConfig = ''
        limit_conn_zone $binary_remote_addr zone=addr:10m;
      '';
      # http2 = false;
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
        locations."/unoconv/pdf" = {
          proxyPass = "http://unoconvserver:3000/unoconv/pdf";
          # Protect from slow loris, 2 connections per IP max
          extraConfig = "limit_conn addr 2;";
        };
        locations."/unoconv/versions" = {
          proxyPass = "http://unoconvserver:3000/unoconv/versions";
          # Protect from slow loris, 2 connections per IP max
          extraConfig = "limit_conn addr 2;";
        };
        locations."/unoconv/formats" = {
          proxyPass = "http://unoconvserver:3000/unoconv/formats";
          # Protect from slow loris, 2 connections per IP max
          extraConfig = "limit_conn addr 2;";
        };
      };
    };
  };
}
