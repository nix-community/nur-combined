# gerbera UPNP/media server
# accessible from TVs on the LAN
# unauthenticated admin and playback UI at http://servo:49152/
#
# supposedly does transcoding, but i poked at it for 10 minutes and couldn't get that working
#
# compatibility:
# - LG TV: music: all working
# - LG TV: videos: mixed
{ lib, ... }:
lib.mkIf false  #< XXX(2024-11-17): WORKS, but no better than any other service; slow to index and transcoding doesn't work
{
  sane.ports.ports."1900" = {
    protocol = [ "udp" ];
    visibleTo.lan = true;
    description = "colin-upnp-for-gerbera";
  };
  sane.ports.ports."49152" = {
    protocol = [ "tcp" "udp" ];  # TODO: is udp required?
    visibleTo.lan = true;
    description = "colin-gerbera-http";
  };

  sane.persist.sys.byStore.plaintext = [
    # persist the index database, since it takes a good 30 minutes to scan the media collection
    { user = "mediatomb"; group = "mediatomb"; mode = "0700"; path = "/var/lib/gerbera"; method = "bind"; }
  ];

  services.mediatomb.enable = true;
  services.mediatomb.serverName = "servo";
  services.mediatomb.transcoding = true;
  services.mediatomb.mediaDirectories = [
    { path = "/var/media/Music"; recursive = true; hidden-files = false; }
    { path = "/var/media/Videos/Film"; recursive = true; hidden-files = false; }
    { path = "/var/media/Videos/Shows"; recursive = true; hidden-files = false; }
  ];
  users.users.mediatomb.extraGroups = [ "media" ];
}
