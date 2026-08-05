{
  lib,
  stdenv,
  rustPlatform,
  buildNpmPackage,
  callPackage,
  jq,
  writableTmpDirAsHomeHook,
  moreutils,
  cargo-tauri,
  glib-networking,
  importNpmLock,
  installDistHook,
  libayatana-appindicator,
  librsvg,
  libsoup_3,
  makeBinaryWrapper,
  nodejs,
  openssl,
  pkg-config,
  webkitgtk_4_1,
  wrapGAppsHook4,

  sources,
  source ? sources.shard,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  inherit (source) pname src version;

  __structuredAttrs = true;
  strictDeps = true;

  # Shard's workspace lockfile is at the repo root; Tauri builds in desktop/src-tauri.
  cargoRoot = "./.";
  buildAndTestSubdir = "desktop/src-tauri";
  cargoDeps = rustPlatform.importCargoLock source.cargoLock."Cargo.lock";

  postPatch = ''
    jq '
      .plugins.updater.endpoints = []
      | .bundle.createUpdaterArtifacts = false
      | .mainBinaryName = "shard-launcher"
      | .build.beforeBuildCommand = "true"
      | .build.frontendDist = "${finalAttrs.passthru.frontend}"
    ' desktop/src-tauri/tauri.conf.json \
    | sponge desktop/src-tauri/tauri.conf.json
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace $cargoDepsCopy/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  tauriBuildFlags = [ "--no-sign" ];

  nativeBuildInputs = [
    cargo-tauri.hook
    jq
    moreutils
    pkg-config
    writableTmpDirAsHomeHook
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    wrapGAppsHook4
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    makeBinaryWrapper
  ];

  buildInputs =
    lib.optionals stdenv.hostPlatform.isLinux [
      glib-networking
      libayatana-appindicator
      librsvg
      libsoup_3
      webkitgtk_4_1
    ]
    ++ [
      openssl
    ];

  env = {
    OPENSSL_NO_VENDOR = 1;
  };

  # doCheck = false;

  postInstall = lib.optionalString stdenv.hostPlatform.isDarwin ''
    mkdir -p "$out/bin"
    appBinary=$(find "$out/Applications" -path '*/Contents/MacOS/*' -type f -print -quit)
    makeBinaryWrapper "$appBinary" "$out/bin/shard-launcher"
  '';

  passthru = {
    cli = callPackage ./cli.nix {
      inherit source;
      meta = lib.removeAttrs finalAttrs.meta [ "mainProgram" ];
    };

    frontend = buildNpmPackage (finalAttrsUI: {
      pname = "${finalAttrs.pname}-ui";
      inherit (finalAttrs) version src;
      sourceRoot = "${finalAttrsUI.src.name}/desktop";

      npmDeps = importNpmLock {
        package = lib.importJSON source.extract."desktop/package.json";
        packageLock = lib.importJSON source.extract."desktop/package-lock.json";
      };
      npmConfigHook = importNpmLock.npmConfigHook;

      nativeBuildInputs = [ nodejs ];

      postPatch = ''
        substituteInPlace package.json \
          --replace-fail '"bun ../scripts/sync-version.mjs"' '"node ../scripts/sync-version.mjs"'
      '';

      npmInstallHook = installDistHook;
      installDistDir = "dist";
    });
  };

  meta = {
    description = "Minimal, content-addressed Minecraft launcher";
    homepage = "https://shard.thomas.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ moraxyc ];
    mainProgram = "shard-launcher";
    platforms = cargo-tauri.hook.meta.platforms;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
