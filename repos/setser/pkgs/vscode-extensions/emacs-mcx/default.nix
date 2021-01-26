{ vscode-utils, stdenv }:
vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
        name = "emacs-mcx";
        publisher = "tuttieee";
        version = "0.24.1";
        sha256 = "sha256-+qIDirOEn+cZu394z38kN/Ih9kmaVyxUR3hl/bBusQs=";
    };
    meta = {
        license = stdenv.lib.licenses.mit;
    };
}
