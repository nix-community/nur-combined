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
  # for serving local files
  # see: go2tv/soapcalls/utils/iptools.go
  networking.firewall.allowedTCPPorts = lib.mkIf cfg.enabled [ 3500 ];
}
