{ npmlock2nix, libwebp, python3 }:
npmlock2nix.v1.shell {
  src = ./.;
  node_modules_attrs = {
    buildInputs = [
      python3 # for node-gyp
      libwebp # cwebp-bin
    ];

    preInstallLinks = {
      "cwebp-bin"."vendor/cwebp" = "${libwebp}/bin/cwebp";
    };
  };
}
