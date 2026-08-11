{ npmlock2nix, libwebp, python3 }:
npmlock2nix.v2.shell {
  src = ./.;
  node_modules_attrs = {
    buildInputs = [
      python3 # for node-gyp
      libwebp # cwebp-bin
    ];

    sourceOverrides = {
      cwebp-bin = sourceInfo: drv: drv.overrideAttrs (old: {
        postPatch = ''
          mkdir -p vendor
          ln -sf "${libwebp}/bin/cwebp" vendor/cwebp
        '';
      });
    };
  };
}
