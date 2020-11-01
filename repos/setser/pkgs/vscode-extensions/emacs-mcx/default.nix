{ vscode-utils, stdenv }:
vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
        name = "emacs-mcx";
        publisher = "tuttieee";
        version = "0.23.5";
        sha256 = "sha256-elh0NapHDUhkfAZ5xXlCI5Mi7/u9e1QjX/YZ7nvJzTo=";
    };
    meta = {
        license = stdenv.lib.licenses.mit;
    };
}