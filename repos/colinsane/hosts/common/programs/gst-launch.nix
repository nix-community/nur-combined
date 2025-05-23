# basic environment tests:
# - `gst-launch-1.0 audiotestsrc ! autoaudiosink`
# - `gst-launch-1.0 videotestsrc ! videoconvert ! autovideosink`
# more usage here: <https://github.com/matthew1000/gstreamer-cheat-sheet>
{ pkgs, ... }:
{
  sane.programs.gst-launch = {
    packageUnwrapped = (
      pkgs.linkBinIntoOwnPackage pkgs.gst_all_1.gstreamer "gst-launch-1.0"
    ).overrideAttrs (base: {
      # XXX the binaries need `GST_PLUGIN_SYSTEM_PATH_1_0` set to function.
      # nixpkgs sets that to /run/current-system/sw/lib/gstreamer-1.0 and /etc/profiles/per-user/colin/lib/gstreamer-1.0,
      # but that only works so long as i install the plugins system-wide (which i don't want to).
      nativeBuildInputs = (base.nativeBuildInputs or []) ++ [
        pkgs.wrapGAppsNoGuiHook
      ];
      buildInputs = (base.buildInputs or []) ++ (with pkgs; [
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
        gst_all_1.gst-libav  # for H.264 decoding
        pipewire
      ]);
    });
    sandbox.method = null;  #< TODO: sandbox
  };
}
