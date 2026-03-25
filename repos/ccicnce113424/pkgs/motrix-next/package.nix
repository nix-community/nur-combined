{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  cargo-tauri,
  pnpm_10,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  pkg-config,
  jq,
  moreutils,
  glib-networking,
  openssl,
  webkitgtk_4_1,
  libayatana-appindicator,
  wrapGAppsHook4,
  nix-update-script,
}:
let
  pnpm = pnpm_10;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "motrix-next";
  version = "3.4.9";

  src = fetchFromGitHub {
    owner = "AnInsomniacy";
    repo = "motrix-next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-xcReDwLzhBhfVNtikzM8HEuyPOTe17BlWu5EHfhtedU=";
  };

  cargoHash = "sha256-lVvShDQnKEOs/CLOn+0LGAmhVyeBQltk8H7a0vXweHs=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    inherit pnpm;
    hash = "sha256-g4H1A2LYvg2j0HMz5hQptUXxBN1bgt/wW7orBroMs+Q=";
    fetcherVersion = 3;
  };

  nativeBuildInputs = [
    cargo-tauri.hook

    pnpmConfigHook
    pnpm
    nodejs

    pkg-config
    jq
    moreutils
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];
  # we don't want to wrap aria2c
  dontWrapGApps = true;

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    openssl
    webkitgtk_4_1
    libayatana-appindicator
  ];

  cargoRoot = "src-tauri";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  # Deactivate the upstream update mechanism
  postPatch = ''
    jq '
      .bundle.createUpdaterArtifacts = false |
      .plugins.updater = {"active": false, "pubkey": "", "endpoints": []}
    ' \
    src-tauri/tauri.conf.json | sponge src-tauri/tauri.conf.json
  ''
  + lib.optionalString stdenv.hostPlatform.isLinux ''
    substituteInPlace $cargoDepsCopy/*/libappindicator-sys-*/src/lib.rs \
      --replace-fail "libayatana-appindicator3.so.1" "${libayatana-appindicator}/lib/libayatana-appindicator3.so.1"
  '';

  postFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    wrapGApp $out/bin/motrix-next
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--use-github-releases" ]; };

  meta = {
    description = "Full-featured download manager, rebuilt from scratch with Tauri 2, Vue 3, and Rust";
    homepage = "https://github.com/AnInsomniacy/motrix-next";
    changelog = "https://github.com/AnInsomniacy/motrix-next/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      mit
      gpl2Plus
    ];
    sourceProvenance = with lib.sourceTypes; [
      fromSource
      # bundled a modified aria2
      # source available at https://github.com/AnInsomniacy/aria2-builder
      binaryNativeCode
    ];
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "motrix-next";
    platforms = with lib.platforms; linux ++ darwin;
  };
})
