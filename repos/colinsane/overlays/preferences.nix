# personal preferences
# prefer to encode these in `sane.programs`
# resort to this method for e.g. system dependencies, or things which are referenced from too many places.
(self: super: with self; {
  # DISABLE HDCP BLOB in pinephone pro.
  # this is used by u-boot; requires redeploying the bootloader (the SPL, specifically).
  # i can see that nixpkgs does process this option, but the hash of bl31.elf doesn't actually change
  arm-trusted-firmware = super.arm-trusted-firmware.override {
    unfreeIncludeHDCPBlob = false;
  };

  # beam = super.beam.override {
  #   # build erlang without webkit (for servo)
  #   wxGTK32 = wxGTK32.override {
  #     withWebKit = false;
  #   };
  # };

  # evolution-data-server = super.evolution-data-server.override {
  #   # OAuth depends on webkitgtk_4_1: old, forces an annoying recompilation
  #   enableOAuth2 = false;
  # };
  # evolution-data-server-gtk4 = super.evolution-data-server-gtk4.override {
  #   # avoid webkitgtk_6_0 build. lol.
  #   withGtk4 = false;
  # };

  # ffmpeg = super.ffmpeg.override {
  #   # required by mpv for spatial audio; enable it globally to avoid shipping many ffmpegs
  #   # or maybe not: this forces a recompilation of many expensive packages, incl libreoffice and *webkitgtk*.
  #   #   not needed, because *pipewire* does the downmixing.
  #   #   PW uses ffmpeg-headless; not affected by `ffmpeg.override`. it directly calls into `libmysofa`
  #   withMysofa = true;
  # };
  # ffmpeg-full = super.ffmpeg-full.override {
  #   # saves 20 minutes of build time and cross issues, for unused feature
  #   withSamba = false;
  # };

  # gnome-control-center = super.gnome-control-center.override {
  #   # i build goa without the "backend", to avoid webkit_4_1.
  #   # however gnome-control-center *directly* uses goa-backend because it manages the accounts...
  #   # so if you really need gnome-control center, then here we are, re-enabling the goa backend.
  #   gnome-online-accounts = gnome-online-accounts.override {
  #     enableBackend = true;
  #   };
  # };
  # gnome-online-accounts = super.gnome-online-accounts.override {
  #   # disables the upstream "goabackend" feature -- presumably "Gnome Online Accounts Backend"
  #   # frees us from webkit_4_1, in turn.
  #   # XXX(2024-11-19): gnome-online-accounts no longer depends on webkitgtk at all ??
  #   enableBackend = false;
  #   # gvfs = super.gvfs.override {
  #   #   # saves 20 minutes of build time and cross issues, for unused feature
  #   #   samba = null;
  #   # };
  # };

  # gvfs = super.gvfs.override {
  #   # saves 20 minutes of build time and cross issues, for unused feature
  #   samba = null;
  # };

  # phog = super.phog.override {
  #   # disable squeekboard because it takes 20 minutes to compile when emulated
  #   squeekboard = null;
  # };

  rsyslog = super.rsyslog.override {
    # XXX(2024-07-28): required for cross compilation
    withGcrypt = false;
  };

  # swaynotificationcenter = super.swaynotificationcenter.override {
  #   gvfs = gvfs.override {
  #     # saves 20 minutes of build time and cross issues, for unused feature
  #     samba = null;
  #   };
  # };

  # 2023/12/10: zbar barcode scanner: used by megapixels, frog.
  # the video component does not cross compile (qt deps), but i don't need that.
  zbar = super.zbar.override { enableVideo = false; };
})
