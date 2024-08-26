{ pkgs, ... }: {
  sane.programs.gnome-clocks = {
    packageUnwrapped = pkgs.gnome-clocks.overrideAttrs (upstream: {
      # TODO: upstream this
      buildInputs = upstream.buildInputs ++ (with pkgs; [
        # gnome-clocks needs `playbin` (gst-plugins-base) and `scaletempo` (gst-plugins-good)
        # to play the alarm when a timer expires
        gst_all_1.gstreamer
        gst_all_1.gst-plugins-base
        gst_all_1.gst-plugins-good
      ]);
    });

    buildCost = 1;
    sandbox.method = "bwrap";
    sandbox.whitelistAudio = true;
    sandbox.whitelistDbus = [ "user" ];  #< required (alongside .config/dconf) to remember timers
    sandbox.whitelistWayland = true;
    sandbox.extraPaths = [
      ".config/dconf"  # required (alongside dbus) to remember timers
    ];
    suggestedPrograms = [ "dconf" ];
  };
}
