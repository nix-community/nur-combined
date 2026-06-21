{
  lib,
  stdenv,
  rustPlatform,
  nix-update-script,
  cacert,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  nodejs_22,
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
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "Darkatse";
    repo = "TauriTavern";
    tag = "v${version}";
    hash = "sha256-jLvW3PWv0zu8cJXXw0fnJt5WaxfcTasiYhTxRDsChzA=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname version src;
    pnpm = pnpm_10;
    fetcherVersion = 3;
    hash = "sha256-qD/iQmG9YZ0byrnXHXuPNCxL5MLnqAJNfu2mA1OR/w4=";
  };

  tauritavern-web = stdenv.mkDerivation {
    pname = "${pname}-web";
    inherit version src pnpmDeps;

    nativeBuildInputs = [
      pnpmConfigHook
      pnpm_10
      nodejs_22
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
  cargoHash = "sha256-n2PZ+fHv8qiT4GmACU11VFSrWx5DVB6Q00QV93DFIaE=";
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
    nodejs_22
    pkg-config
    pnpm_10
    pnpmConfigHook
    wrapGAppsHook4
  ];

  buildInputs = [
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

  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ libayatana-appindicator ]}"
    )
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "SillyTavern backend rebuilt with Tauri and Rust";
    homepage = "https://github.com/Darkatse/TauriTavern";
    changelog = "https://github.com/Darkatse/TauriTavern/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "tauritavern";
    platforms = lib.platforms.linux;
    sourceProvenance = with lib.sourceTypes; [ fromSource ];
  };
})
