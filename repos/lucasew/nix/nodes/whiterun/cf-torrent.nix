{ pkgs, lib, config, ... }:
let
  app = pkgs.callPackage pkgs.bumpkin.unpackedInputs.cf-torrent.outPath {};
in {
  networking.ports.cf-torrent.enable = true;

  services.nginx.virtualHosts."cf-torrent.${config.networking.hostName}.${config.networking.domain}" = {
    locations."/" = {
      proxyPass = "http://127.0.0.1:${toString config.networking.ports.cf-torrent.port}";
      proxyWebsockets = true;
    };
  };
  systemd.services.cf-torrent = {
    inherit (app.meta) description;
    wantedBy = [ "multi-user.target" ];
    environment = {
      PORT="${toString config.networking.ports.cf-torrent.port}";
    };
    script = ''
      ${app}/bin/sveltekit-cftorrent
    '';
  };
}
