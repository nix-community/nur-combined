{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  fetchpatch,
  aria2,
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
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "motrix-next";
  version = "3.4.8";

  src = fetchFromGitHub {
    owner = "AnInsomniacy";
    repo = "motrix-next";
    tag = "v${finalAttrs.version}";
    hash = "sha256-z1SCRfIzA/w/V2TO0Q2PJM5ZB9kSXMS7ehJyVipxrfA=";
  };

  pnpm = pnpm_10;
  aria2 = aria2.overrideAttrs {
    pname = "motrix-next-aria2";
    patches = [
      (fetchpatch {
        url = "https://github.com/AnInsomniacy/aria2-builder/commit/bc2e0fe438ae2de0a44dfb22ed3851dc11b81319.patch";
        hash = "sha256-gvSJ5xbm1n86ousKji1drSax+lZy7pC+Y5hgejyxKCg=";
      })
    ];
  };

  cargoHash = "sha256-+CpL8r4btFZ1ODDuQh+7gjr0dLvQWOSQDMOmRxqkkcA=";

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs)
      pname
      version
      src
      pnpm
      ;
    hash = "sha256-g4H1A2LYvg2j0HMz5hQptUXxBN1bgt/wW7orBroMs+Q=";
    fetcherVersion = 3;
  };

  nativeBuildInputs = [
    cargo-tauri.hook

    pnpmConfigHook
    finalAttrs.pnpm
    nodejs

    pkg-config
    jq
    moreutils
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ wrapGAppsHook4 ];

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

  postFixup = ''
    rm -f $out/bin/motrixnext-aria2c
    ln -s ${lib.getExe' finalAttrs.aria2 "aria2c"} $out/bin/motrixnext-aria2c

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
    maintainers = with lib.maintainers; [ ccicnce113424 ];
    mainProgram = "motrix-next";
    platforms = with lib.platforms; linux ++ darwin;
  };
})
