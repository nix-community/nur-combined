{
    lib,
    callPackage,
    rustPlatform,
    fetchFromGitHub,
    pkg-config,
    llvmPackages,
}:
let
    librusty_v8 = callPackage ../librusty_v8/package.nix { };
in

rustPlatform.buildRustPackage {
    pname = "fresh";
    version = "0.1.52-unstable-2025-12-16";

    src = fetchFromGitHub {
        owner = "sinelaw";
        repo = "fresh";
        rev = "58ce0d35b0cec10e0492a7796b451a111118ed61";
        hash = "sha256-kUN8cUctgVkFZ1zfy4dojSRce5lpp0K38/Uvg9upc8Q=";
    };

    cargoHash = "sha256-DbE/dAxsvExvTijk2hAQ6LAb/XcdYahy8wFk36fe8Oc=";
    strictDeps = true;

    nativeBuildInputs = [
        pkg-config
        rustPlatform.bindgenHook
    ];

    LIBCLANG_PATH = lib.makeLibraryPath [
        llvmPackages.libclang.lib
    ];
    RUSTY_V8_ARCHIVE = librusty_v8;

    postInstall = ''
        mkdir -p $out/share/fresh-editor

          cp -r queries $out/share/fresh-editor/
          cp -r themes $out/share/fresh-editor/
          cp -r keymaps $out/share/fresh-editor/
          cp -r plugins $out/share/fresh-editor/
    '';

    doCheck = false;

    meta = {
        description = "Text editor for your terminal: easy, powerful and fast";
        homepage = "https://github.com/sinelaw/fresh/";
        changelog = "https://github.com/sinelaw/fresh/blob/master/CHANGELOG.md";
        license = lib.licenses.gpl2Only;
        mainProgram = "fresh";
    };
}
