# personal preferences
# prefer to encode these in `sane.programs`
# resort to this method for e.g. system dependencies, or things which are referenced from too many places.
(self: super: with self; {
  beam = super.beam.override {
    # build erlang without webkit (for servo)
    wxGTK32 = wxGTK32.override {
      withWebKit = false;
    };
  };

  gnome = super.gnome.overrideScope (gself: gsuper: with gself; {
    evolution-data-server = gsuper.evolution-data-server.override {
      # OAuth depends on webkitgtk_4_1: old, forces an annoying recompilation
      enableOAuth2 = false;
    };
    gnome-control-center = gsuper.gnome-control-center.override {
      # i build goa without the "backend", to avoid webkit_4_1.
      # however gnome-control-center *directly* uses goa-backend because it manages the accounts...
      # so if you really need gnome-control center, then here we are, re-enabling the goa backend.
      gnome-online-accounts = self.gnome-online-accounts.override {
        enableBackend = true;
      };
    };
    # gnome-shell = gsuper.gnome-shell.override {
    #   evolution-data-server-gtk4 = evolution-data-server-gtk4.override {
    #     # avoid webkitgtk_6_0 build. lol.
    #     withGtk4 = false;
    #   };
    # };
  });
  gnome-online-accounts = super.gnome-online-accounts.override {
    # disables the upstream "goabackend" feature -- presumably "Gnome Online Accounts Backend"
    # frees us from webkit_4_1, in turn.
    enableBackend = false;
    gvfs = gvfs.override {
      # saves 20 minutes of build time and cross issues, for unused feature
      samba = null;
    };
  };

  phog = super.phog.override {
    # disable squeekboard because it takes 20 minutes to compile when emulated
    squeekboard = null;
  };

  pipewire = super.pipewire.override {
    # avoid a dep on python3.10-PyQt5, which has mixed qt5 versions.
    # this means we lose firewire support (oh well..?)
    # N.B.: ffado is already disabled for cross builds: this is only to prevent weird `targetPackages` related stuff.
    # try `nix build '.#hostPkgs.moby.megapixels'` for example
    ffadoSupport = false;
    # ffado = null;
  };

  # pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
  #   (pySelf: pySuper: {
  #     keyring = (pySuper.keyring.override {
  #       # jaraco-classes doesn't cross compile, but it looks like `keyring`
  #       # has some _temporary_ fallback logic for when jaraco-classes isn't
  #       # installed (i.e. may break in future).
  #       jaraco-classes = null;
  #     }).overrideAttrs (upstream: {
  #       postPatch = (upstream.postPatch or "") + ''
  #         sed -i /jaraco.classes/d setup.cfg
  #       '';
  #     });
  #   })
  # ];

  # 2023/12/10: zbar barcode scanner: used by megapixels, frog.
  # the video component does not cross compile (qt deps), but i don't need that.
  zbar = super.zbar.override { enableVideo = false; };
})
