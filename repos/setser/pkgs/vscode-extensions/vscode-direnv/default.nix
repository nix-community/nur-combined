{ vscode-utils, stdenv }:
vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
        name = "vscode-direnv";
        publisher = "Rubymaniac";
        version = "0.0.2";
        sha256 = "sha256-TVvjKdKXeExpnyUh+fDPl+eSdlQzh7lt8xSfw1YgtL4=";
    };
    meta = {
        license = stdenv.lib.licenses.mit;
    };
}