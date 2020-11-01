{ vscode-utils, stdenv }:
vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
        name = "rust";
        publisher = "rust-lang";
        version = "0.7.8";
        sha256 = "sha256-Y33agSNMVmaVCQdYd5mzwjiK5JTZTtzTkmSGTQrSNg0=";
    };
    meta = {
      license = stdenv.lib.licenses.mit;
    };
}