# personal preferences
# prefer to encode these in `sane.programs`
# resort to this method for e.g. system dependencies, or things which are referenced from too many places.
(self: super: with self; {
  gnome = super.gnome.overrideScope' (gself: gsuper: with gself; {
    evolution-data-server = gsuper.evolution-data-server.override {
      # OAuth depends on webkitgtk_4_1: old, forces an annoying recompilation
      enableOAuth2 = false;
      gnome-online-accounts = gnome-online-accounts.override {
        # avoid webkitgtk_4_1 build
        enableBackend = false;
      };
    };
    # gnome-shell = gsuper.gnome-shell.override {
    #   evolution-data-server-gtk4 = evolution-data-server-gtk4.override {
    #     # avoid webkitgtk_6_0 build. lol.
    #     withGtk4 = false;
    #   };
    # };
  });

  phog = super.phog.override {
    # disable squeekboard because it takes 20 minutes to compile when emulated
    squeekboard = null;
    gnome.gnome-shell = gnome.gnome-shell.override {
      evolution-data-server-gtk4 = evolution-data-server-gtk4.override {
        gnome-online-accounts = gnome-online-accounts.override {
          # disables the upstream "goabackend" feature -- presumably "Gnome Online Accounts Backend"
          # frees us from webkit_4_1, in turn.
          enableBackend = false;
          gvfs = gvfs.override {
            # saves 20 minutes of build time and cross issues, for unused feature
            samba = null;
          };
        };
      };
    };
  };

  pipewire = super.pipewire.override {
    # avoid a dep on python3.10-PyQt5, which has mixed qt5 versions.
    # this means we lose firewire support (oh well..?)
    ffadoSupport = false;
  };

  pythonPackagesExtensions = super.pythonPackagesExtensions ++ [
    (pySelf: pySuper: {
      keyring = (pySuper.keyring.override {
        # jaraco-classes doesn't cross compile, but it looks like `keyring`
        # has some _temporary_ fallback logic for when jaraco-classes isn't
        # installed (i.e. may break in future).
        jaraco-classes = null;
      }).overrideAttrs (upstream: {
        postPatch = (upstream.postPatch or "") + ''
          sed -i /jaraco.classes/d setup.cfg
        '';
      });
    })
  ];

  qemu = super.qemu.override {
    # 2023/09/07: see <https://github.com/NixOS/nixpkgs/pull/252874>
    # fixes an eval-time recursion error
    # should be safe to remove after next staging -> master merge
    jackSupport = false;
  };
})
