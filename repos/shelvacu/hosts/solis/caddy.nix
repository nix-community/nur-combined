{ vacuModules, ... }:
{
  imports = [ vacuModules.caddy-hsts ];
  services.caddy.enable = true;
  networking.firewall = {
    allowedTCPPorts = [
      80
      443
    ];
    allowedUDPPorts = [ 443 ];
  };
}
