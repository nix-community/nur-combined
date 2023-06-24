self: super: {
  calibre-dedrm =
    super.calibre.overrideAttrs (oa: {
      # We want to have pycryptodome around in order to support DeDRM
      nativeBuildInputs = oa.nativeBuildInputs ++ [ self.python3Packages.pycryptodome ];
    });
}
