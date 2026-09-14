{
    lib,
    callPackage,
    rustPlatform,
    fetchFromGitHub,
    pkg-config,
    llvmPackages,
}:
let
    librusty_v8 = callPackage ../../deps/librusty_v8/package.nix { };
in
rustPlatform.buildRustPackage {
    pname = "fresh";
    version = "unstable-2026-09-13";

    src = fetchFromGitHub {
        owner = "sinelaw";
        repo = "fresh";
        rev = "a3e6722a2e6b4259df88b89e1e4e593f071f44d1";
        hash = "sha256-+hcI99nBYy4dLdbjIyA7yH4zRmjLXTOyEK8TkPhTwSQ=";
    };

    cargoLock.lockFile = ./Cargo.lock;
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
