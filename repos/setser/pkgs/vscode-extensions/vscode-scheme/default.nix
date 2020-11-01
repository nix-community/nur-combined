{ vscode-utils, stdenv }:
vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
        name = "vscode-scheme";
        publisher = "sjhuangx";
        version = "0.4.0";
        sha256 = "sha256-BN+C64YQ2hUw5QMiKvC7PHz3II5lEVVy0Shtt6t3ch8=";
    };
    meta = {
        license = stdenv.lib.licenses.mit;
    };
}