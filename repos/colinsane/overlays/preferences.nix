# personal preferences
# prefer to encode these in `sane.programs`
# resort to this method for e.g. system dependencies, or things which are referenced from too many places.
(self: super: with self; {
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
})
