# TROUBLESHOOTING:
# - turn the tv off and on again (no, really...)
#
# SANITY CHECKS:
# - `go2tv -u 'https://uninsane.org/share/AmenBreak.mp4'`
#   - LGTV: works
# - `go2tv -u 'https://youtu.be/p3G5IXn0K7A'`
#   - LGTV: FAILS ("this file cannot be recognized")
#     - no fix via transcoding, altering the URI, etc.
# - `go2tv -v /mnt/servo-media/Videos/Shows/bebop/session1.mkv`
#   - LGTV: works
# - `go2tv -tc -v /mnt/servo-media/Videos/Shows/bebop/session1.mkv`
#   - LGTV: works
#
# WHEN TO TRANSCODE:
# - mkv container + mpeg-2 video + AC-3/48k stereo audio:
#   - LGTV: no transcoding needed
# - mkv container + H.264 video + AAC/48k 5.1 audio:
#   - LGTV: no transcoding needed
# - mp4 container + H.264 video + MP3/48k stereo audio:
#   - LGTV: no transcoding needed
# - mp4 container + H.264 video + AAC/44k1 stereo audio:
#   - LGTV: no transcoding needed
# - mkv container + H.265 video + E-AC-3/48k stereo audio:
#   - LGTV: no transcoding needed
{ config, lib, pkgs, ... }:
let
  cfg = config.sane.programs.go2tv;
in
{
  sane.programs.go2tv = {
    package = pkgs.go2tv.overrideAttrs (orig: {
      # SSDP doesn't do well with default firewall rules.
      # - go2tv sends a UDP M-Search from localhost port P to the broadcast address.
      # - UPNP sinks respond to localhost port P.
      # - firewall can't track that "connection", because the address which contacts us isn't the same as the address we queried.
      #
      # to workaround this, force go2tv to query from a fixed *source* port.
      # then the responses will likewise be to a fixed *dest* port, and we can open that port
      postPatch = (orig.postPatch or "") + ''
        substituteInPlace devices/devices.go \
          --replace 'ssdp.Search(ssdp.All, delay, "")' 'ssdp.Search(ssdp.All, delay, "0.0.0.0:1901")'
      '';
    });
  };

  # necessary to discover local UPNP endpoints
  networking.firewall.allowedUDPPorts = lib.mkIf cfg.enabled [ 1901 ];
  # for serving local files
  # see: go2tv/soapcalls/utils/iptools.go
  networking.firewall.allowedTCPPorts = lib.mkIf cfg.enabled [ 3500 ];
}
