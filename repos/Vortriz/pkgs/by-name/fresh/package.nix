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
    version = "0.1.44-unstable-2025-12-16";

    src = fetchFromGitHub {
        owner = "sinelaw";
        repo = "fresh";
        rev = "ee25c33e47028300d7c211c6657771ede6ab7ceb";
        hash = "sha256-bTvX6syN8RkJ/5A4qCRZmCU2hfDmkGYbW/vl3wyvetg=";
    };

    cargoHash = "sha256-IglklvhsR0MgZY3sqKGSbDtXlS0S31yWnKXtjfrhw9o=";
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
