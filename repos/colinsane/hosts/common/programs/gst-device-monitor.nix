# gst-device-monitor: gstreamer debugging tool.
# - `gst-device-monitor-1.0 Audio/Sink`  #< show all audio sinks
# - `gst-device-monitor-1.0 Audio/Source`  #< show all audio sources (microphones)
# - `gst-device-monitor-1.0 Video/Source`  #< show all video sources (cameras)
{ pkgs, ... }:
{
  sane.programs.gst-device-monitor = {
    packageUnwrapped = (pkgs.linkIntoOwnPackage pkgs.gst_all_1.gst-plugins-base [
      "bin/gst-device-monitor-1.0"
      "share/man/man1/gst-device-monitor-1.0.1.gz"
    ]).overrideAttrs (base: {
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

    sandbox.method = "bwrap";
    sandbox.whitelistAudio = true;
    sandbox.extraPaths = [
      "/dev"  # tried, but failed to narrow this down (moby)
      "/run/udev/data"
      "/sys/class/video4linux"
      "/sys/devices"
    ];
  };
}
