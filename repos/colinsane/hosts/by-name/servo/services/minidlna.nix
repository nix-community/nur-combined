# - `man 5 minidlna.conf`
# - `man 8 minidlnad`
#
# this is an extremely simple (but limited) DLNA server:
# - no web UI
# - no runtime configuration -- just statically configure media directories instead
# - no transcoding
# compatibility:
# - LG TV: music: all working
# - LG TV: videos: mixed. i can't see the pattern; HEVC works; H.264 sometimes works.
{ lib, ... }:
lib.mkIf false  #< XXX(2024-11-17): WORKS, but i'm trying gerbera instead for hopefully better transcoding
{
  sane.ports.ports."1900" = {
    protocol = [ "udp" ];
    visibleTo.lan = true;
    description = "colin-upnp-for-minidlna";
  };
  sane.ports.ports."8200" = {
    protocol = [ "tcp" ];
    visibleTo.lan = true;
    description = "colin-minidlna-http";
  };

  services.minidlna.enable = true;

  services.minidlna.settings = {
    media_dir = [
      # A/V/P to restrict a directory to audio/video/pictures
      "A,/var/media/Music"
      "V,/var/media/Videos/Film"
      # "V,/var/media/Videos/Milkbags"
      "V,/var/media/Videos/Shows"
    ];
    notify_interval = 60;
  };

  users.users.minidlna.extraGroups = [ "media" ];
}
