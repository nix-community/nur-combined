{
  lib,
  stdenv,
  rustPlatform,
  nix-update-script,
  cacert,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs,
  pnpm_10,
  cargo-tauri,
  pkg-config,
  wrapGAppsHook4,
  glib-networking,
  gtk3,
  libayatana-appindicator,
  libsoup_3,
  openssl,
  webkitgtk_4_1,
  gst_all_1,
}:

let
  pname = "tauritavern";
  version = "2.1.1";

  src = fetchFromGitHub {
    owner = "Darkatse";
    repo = "TauriTavern";
    tag = "v${version}";
    hash = "sha256-3M+hHciouiET8RcA1NAud9cB8TXnAMOPLnvPx3nfcEU=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-Ka+RJi2+buqWwGTZLN8apA+ClUYrgaQS/1VLi2/6+90=";
  };

  tauritavern-web = stdenv.mkDerivation {
    pname = "${pname}-web";
    inherit version src pnpmDeps;

    nativeBuildInputs = [
      pnpmConfigHook
      pnpm_10
      nodejs
    ];

    buildPhase = ''
      runHook preBuild
      pnpm run web:build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out
      cp -r src/dist $out/
      mkdir -p $out/agent-system
      cp -r src/scripts/extensions/agent-system/dist $out/agent-system/
      runHook postInstall
    '';
  };
in

rustPlatform.buildRustPackage (finalAttrs: {
  inherit
    pname
    version
    src
    pnpmDeps
    ;

  cargoRoot = "src-tauri";
  cargoHash = "sha256-hyxn9TVlEfWXYXqph1rHkkx10QldKjAUu2JAFOUk+yU=";
  buildAndTestSubdir = finalAttrs.cargoRoot;

  preBuild = ''
    cp -r ${tauritavern-web}/dist src/
    mkdir -p src/scripts/extensions/agent-system/dist
    cp -r ${tauritavern-web}/agent-system/* src/scripts/extensions/agent-system/dist/
  '';

  preCheck = ''
    export TMPDIR=/tmp
    export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
  '';

  checkFlags = [
    "--skip=import_chat_payload_preserves_jsonl_suffix"
    "--skip=list_recent_chat_summaries_limits_results_and_keeps_pinned"
  ];

  tauriBuildFlags = [ "--ignore-version-mismatches" ];

  nativeBuildInputs = [
    cacert
    cargo-tauri.hook
    nodejs
    pkg-config
    pnpm_10
    pnpmConfigHook

  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    glib-networking
    gtk3
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    libayatana-appindicator
    libsoup_3
    openssl
    webkitgtk_4_1
  ];

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libayatana-appindicator ]}"
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "SillyTavern backend rebuilt with Tauri and Rust";
    longDescription = ''
      TauriTavern is a cross-platform rewrite of SillyTavern using Tauri (Rust)
      for the backend, featuring agent orchestration, multi-device sync, and a
      modern Vue 3 frontend.
    '';
    homepage = "https://github.com/Darkatse/TauriTavern";
    changelog = "https://github.com/Darkatse/TauriTavern/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "tauritavern";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
})
