{
    lib,
    rustPlatform,
    fetchFromGitHub,
    pkg-config,
    wrapGAppsHook3,
    atk,
    cairo,
    gdk-pixbuf,
    glib,
    gtk3,
    libsoup_3,
    pango,
    webkitgtk_4_1,
    npmHooks,
    fetchNpmDeps,
    nodejs,
    typst,
    tinymist,
}:

rustPlatform.buildRustPackage rec {
    pname = "typos";
    version = "0.2.5";

    src = fetchFromGitHub {
        owner = "dailydaniel";
        repo = "typos";
        tag = "v${version}";
        hash = "sha256-8MdaJ4cOdY0326joICyZPC3oaCVTYj99/1Sgu1AV23E=";
    };

    cargoLock.lockFile = ./Cargo.lock;

    npmDeps = fetchNpmDeps {
        inherit src;
        sourceRoot = "${src.name}/notes-app";
        hash = "sha256-ie3Ej0ody1s8qnMy85k/tOJwoUeGPlCUjixTZq+oM8E=";
    };

    npmRoot = "notes-app";

    nativeBuildInputs = [
        pkg-config
        wrapGAppsHook3
        npmHooks.npmConfigHook
        nodejs
    ];

    buildInputs = [
        atk
        cairo
        gdk-pixbuf
        glib
        gtk3
        libsoup_3
        pango
        webkitgtk_4_1
    ];

    postPatch = ''
        mkdir -p notes-app/src-tauri/binaries
        cp ${lib.getExe typst} notes-app/src-tauri/binaries/typst-x86_64-unknown-linux-gnu
        cp ${lib.getExe tinymist} notes-app/src-tauri/binaries/tinymist-x86_64-unknown-linux-gnu
        chmod +x notes-app/src-tauri/binaries/*
    '';

    preBuild = ''
        npm --prefix "$npmRoot" run build
    '';

    meta = {
        description = "A Typst-native note-taking system powered by Rust and Tauri with typed metadata, cross-references, backlinks, and knowledge graph visualization";
        homepage = "https://github.com/dailydaniel/typos";
        license = lib.licenses.asl20;
        mainProgram = "notes-app";
    };
}
