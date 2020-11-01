{ vscode-utils, stdenv }:
vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
    name = "magit";
      publisher = "kahole";
        version = "0.5.1";
        sha256 = "sha256-yCetfMykrrN/q/Wf3LCwKBTC3ftr3orhosAXFEWngrI=";
    };
    meta = {
        license = stdenv.lib.licenses.mit;
    };
}