# v4l-utils ships `media-ctl`, for camera config/debugging.
# - `media-ctl --print-topology`
# enable the pinephone rear camera like this:
# - `media-ctl -d /dev/media0 --links '"ov5640 3-004c":0->"sun6i-csi-bridge":0[1]'`
# - `media-ctl -d /dev/media0 --set-v4l2 '"ov5640 3-004c":0[fmt:UYVY8_2X8/1280x720]'`  (doesn't work!)
# - `ffmpeg -s 1280x720 -f video4linux2 -i /dev/video1 -vframes 1 selfie.jpg`  (doesn't work!)
# - source: <https://wiki.postmarketos.org/wiki/PINE64_PinePhone_(pine64-pinephone)#Cameras>
#
# query layouts:
# - `v4l2-ctl -d /dev/video1 --all` (front camera?)
# - `v4l2-ctl -d /dev/video2 --all` (rear camera?)
# - `v4l2-ctl --list-ctrls-menus -d /dev/video1` (show rotation/flips)
{ ... }:
{
  sane.programs.v4l-utils = {
    # packageUnwrapped = pkgs.v4l-utils.override {
    #   # XXX(2024-09-09): gui does not cross compile due to qtbase / wrapQtAppsHook
    #   # XXX(2025-08-06): v4l-utils cross compiles, thanks to <https://github.com/NixOS/nixpkgs/pull/429900>
    #   withGUI = false;
    # };
    sandbox.method = null;  #< TODO: sandbox
  };
}
