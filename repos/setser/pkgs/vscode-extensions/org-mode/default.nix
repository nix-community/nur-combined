{ vscode-utils, lib }:
vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
        name = "org-mode";
        publisher = "vscode-org-mode";
        version = "1.0.0";
        sha256 = "sha256-o9CIjMlYQQVRdtTlOp9BAVjqrfFIhhdvzlyhlcOv5rY=";
    };
    meta = {
      license = lib.licenses.mit;
    };
}
