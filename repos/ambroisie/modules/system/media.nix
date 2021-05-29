# Abstracting away the need for a common 'media' group

{ config, lib, ... }:
let
  mediaServices = with config.my.services; [
    calibre-web
    jellyfin
    pirate
    sabnzbd
    transmission
  ];
  needed = builtins.any (service: service.enable) mediaServices;
in
{
  config.users.groups.media = lib.mkIf needed { };
}
