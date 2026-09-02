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
    version = "unstable-2026-09-02";

    src = fetchFromGitHub {
        owner = "sinelaw";
        repo = "fresh";
        rev = "18c98b90dd2367df3e120165dcffa1a3c55b28d1";
        hash = "sha256-aeZII2g+ZNmiqQLXxVfAt/0xzHiBAbrIyApbG2fS1Jg=";
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
