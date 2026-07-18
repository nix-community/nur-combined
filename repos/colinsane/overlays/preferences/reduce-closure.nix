self: super: {
  beam = super.beam.override {
    # build erlang without webkit (for servo)
    wxSupport = false;
    # old way: keep wxGTK32, but disable webkitgtk components
    # doesn't apply anymore: see <repo:nixos/nixpkgs:pkgs/top-level/beam-packages.nix>
    # wxGTK32 = self.wxGTK32.override {
    #   withWebKit = false;
    # };
  };

  evolution-data-server = super.evolution-data-server.override {
    # OAuth depends on webkitgtk_4_1: old, forces an annoying recompilation
    enableOAuth2 = false;
  };
  # evolution-data-server-gtk4 = super.evolution-data-server-gtk4.override {
  #   # avoid webkitgtk_6_0 build. lol.
  #   # N.B.(2026-02-02): this breaks `gnome-calendar` build: "Run-time dependency libedataserverui4-1.0 found: NO (tried pkgconfig)"
  #   # N.B.(2026-07-18): this breaks `stamp` build: "Dependency "libedataserverui4-1.0" not found, tried pkgconfig"
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
  #   # samba = null;
  #   # XXX(2025-07-02): avoid cross compilation error on thin-provisioning-tools by disabling the thing which pulls it in.
  #   # see: <https://github.com/stratis-storage/devicemapper-rs/issues/965>
  #   # however, thin-provisioning-tools uses `devicemapper` crate -- not `devicemapper-sys`;
  #   # unclear if `devicemapper` intends to support this; manually enabling the feature did not fix any build error;
  #   # my error seems to be that `devicemapper` is compiled _to the wrong platform_ (maybe the issue is in thin-provisioning-tools' build script)
  #   udevSupport = false;
  # };

  # phog = super.phog.override {
  #   # disable squeekboard because it takes 20 minutes to compile when emulated
  #   squeekboard = null;
  # };

  # XXX(2026-03-29): this is specifically targeted to remove qtwebengine from krita's closure
  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (pyself: pysuper: {
      pyqt6 = pysuper.pyqt6.override {
        withPdf = false;
      };
      pyside6 = pysuper.pyside6.override {
        python = pyself.python // {
          pkgs = pyself.python.pkgs.overrideScope (self': super': {
            qt6 = super'.qt6.overrideScope (_: _: {
              qtwebengine = null;
            });
          });
        };
      };
      # less targeted alternative to removing qtwebengine from the pyside6 closure
      # qt6 = pysuper.qt6.overrideScope (_: _: {
      #   qtwebengine = null;
      # });
    })
  ];

  # rsyslog = super.rsyslog.override {
  #   # XXX(2024-07-28): required for cross compilation
  #   withGcrypt = false;
  # };

  # swaynotificationcenter = super.swaynotificationcenter.override {
  #   gvfs = gvfs.override {
  #     # saves 20 minutes of build time and cross issues, for unused feature
  #     samba = null;
  #   };
  # };
}
