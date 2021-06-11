{ vscode-utils, lib }:
vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
        name = "emacs-mcx";
        publisher = "tuttieee";
        version = "0.32.0";
        sha256 = "sha256-0dxkUyowr4ViU9xSWlmwg+KkclidKeSwj+KoAYWX3NQ=";
    };
    meta = {
        license = lib.licenses.mit;
    };
}
