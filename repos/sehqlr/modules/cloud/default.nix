{ config, lib, pkgs, ... }: {

  imports = [ ./nextcloud.nix ];

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowPing = true;

  security.acme.acceptTerms = true;

  # services.nginx = {
  #   enable = true;
  #   statusPage = true;
  #   virtualHosts."samhatfield.me" = {
  #     addSSL = true;
  #     enableACME = true;
  #     locations."/" = {
  #       index = "index.html";
  #     };
  #   };
  # };
}