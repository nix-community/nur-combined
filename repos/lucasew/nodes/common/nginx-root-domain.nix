{ config, pkgs, ... }:
let
  template = ''
<!DOCTYPE html>
  <html>
    <head>
      <meta charset="utf-8">
      <title>NixOS - ${config.networking.hostName}</title>
    </head>

    <body>
      <h1>Hello, ${config.networking.hostName}</h1>
    </body>

  </html>
  '';
in
{
  environment.etc."rootdomain/index.html".source = pkgs.writeText "template.html" template;

  services.nginx.virtualHosts."${config.networking.hostName}.${config.networking.domain}" = {
    locations."/".root = "/etc/rootdomain";
  };
}
