# gst-device-monitor: gstreamer debugging tool.
# - `gst-device-monitor-1.0 Audio/Sink`  #< show all audio sinks
# - `gst-device-monitor-1.0 Audio/Source`  #< show all audio sources (microphones)
# - `gst-device-monitor-1.0 Video/Source`  #< show all video sources (cameras)
# the output will include things like
#   `gst-launch-1.0 pipewiresrc target-object=90 ! ...`
# in which case, view it like (for a camera): `gst-launch-1.0 pipewiresrc target-object=90 ! glimagesink`
{ pkgs, ... }:
{
  sane.programs.gst-device-monitor = {
    packageUnwrapped = (
      pkgs.linkBinIntoOwnPackage pkgs.gst_all_1.gst-plugins-base "gst-device-monitor-1.0"
    ).overrideAttrs (base: {
      # XXX the binaries need `GST_PLUGIN_SYSTEM_PATH_1_0` set to function,
      # but nixpkgs doesn't set those (TODO: upstream this!)
      nativeBuildInputs = (base.nativeBuildInputs or []) ++ [
        pkgs.wrapGAppsNoGuiHook
      ];
      buildInputs = (base.buildInputs or []) ++ [
        pkgs.gst_all_1.gst-plugins-base  #< required to find Audio/Sink
        pkgs.gst_all_1.gst-plugins-good  #< required to find Audio/Source and Video/Source
        pkgs.pipewire  #< required for Video/Source (video4linux)
      ];
    });

    sandbox.whitelistAudio = true;
    sandbox.extraPaths = [
      "/dev"  # tried, but failed to narrow this down (moby)
      "/run/udev/data"
      "/sys/class/video4linux"
      "/sys/devices"
    ];
  };
}
