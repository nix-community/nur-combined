{ lib, ... }:
let
  fs = lib.fileset;
  webRoot = fs.toSource {
    root = ./.;
    fileset = ./index.html;
  };
in
{
  services.caddy.virtualHosts = {
    "violingifts.com" = {
      serverAliases = [
        "www.violingifts.com"
        "www.theviolincase.com"
        "shop.theviolincase.com"
      ];
      vacu.hsts = true;
      extraConfig = "redir https://theviolincase.com{uri}";
    };
    "theviolincase.com" = {
      vacu.hsts = true;
      extraConfig = ''
        root ${webRoot}
        file_server
      '';
    };
  };
}
