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
  desktop-file-utils,
  xdg-utils,
  nix-update-script,
}:
let
  pnpm = pnpm_10;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "motrix-next";
  version = "3.6.0";

  src = fetchFromGitHub {
    owner = "AnInsomniacy";
    repo = "motrix-next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-J8r4FhTqlyV1ZqcjWtQO2w4I4GJVQ20pU0ksD89qNVk=";
  };

  cargoHash = "sha256-rxsal3mtlJWkffL/9++GvbVgunL/YSOOyBz3JNmjghQ=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    inherit pnpm;
    hash = "sha256-rCer8jUaFJV2nIcq+cn0ZPYBRpB0Aa071Qusyarq65I=";
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

  checkFlags = lib.optional stdenv.hostPlatform.isDarwin "--skip=commands::protocol::tests::macos_tests::get_default_handler_bundle_id_returns_some_for_https";

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

  preFixup = lib.optionalString stdenv.hostPlatform.isLinux ''
    gappsWrapperArgs+=(
      --suffix PATH : ${
        lib.makeBinPath [
          desktop-file-utils
          xdg-utils
        ]
      }
      # fix Nvidia issues with Tauri
      # https://github.com/tauri-apps/tauri/issues/9394#issuecomment-3795449374
      --set-default __NV_DISABLE_EXPLICIT_SYNC 1
    )
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
