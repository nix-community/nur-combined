{ vscode-utils, stdenv }:
vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
    name = "magit";
      publisher = "kahole";
        version = "0.6.2";
        sha256 = "sha256-MHmhd4EmQ/joYulyMSRW6wNbWwDxHJsF05abZMkMIWM=";
    };
    meta = {
        license = stdenv.lib.licenses.mit;
    };
}
