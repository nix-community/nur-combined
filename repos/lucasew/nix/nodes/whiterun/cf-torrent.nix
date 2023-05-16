{ pkgs, lib, config, ... }:
let
  port = 33444;
  app = pkgs.callPackage pkgs.bumpkin.unpackedInputs.cf-torrent.outPath {};
in {
  services.nginx.virtualHosts."cf-torrent.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString port}";
      proxyWebsockets = true;
    };
  };
  systemd.services.cf-torrent = {
    inherit (app.meta) description;
    wantedBy = [ "multi-user.target" ];
    environment = {
      PORT="${toString port}";
    };
    script = ''
      ${app}/bin/sveltekit-cftorrent
    '';
  };
}
