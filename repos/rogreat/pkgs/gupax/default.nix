{
  autoPatchelfHook,
  copyDesktopItems,
  fetchFromGitHub,
  git,
  lib,
  libGL,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrandr,
  makeDesktopItem,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gupax";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "hinto-janai";
    repo = "gupax";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BBFovEZwjZNcC8eEnp3IgQf70O1QCJ+tdwxHk+vUp1E=";
    leaveDotGit = true; # build.rs uses git
  };

  cargoHash = "sha256-7Kew11N/rakHLhKBu+BUM3f4AP9xDZl1xARpbyqHCFY=";

  checkFlags = [
    # Test requires filesystem write outside of sandbox.
    "--skip disk::test::create_and_serde_gupax_p2pool_api"
    # Tests require access to CA certificates.
    "--skip disk::tests::test::create_and_serde_gupax_p2pool_api"
    "--skip helper::tests::test::public_api_deserialize"
    "--skip helper::xvb::algorithm::test::test_manual_p2pool_mode"
    "--skip helper::xvb::algorithm::test::test_manual_xvb_mode"
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    git
    pkg-config
  ];

  buildInputs = [
    openssl
    # https://github.com/NixOS/nixpkgs/issues/225963
    stdenv.cc.cc.libgcc or null
  ];

  runtimeDependencies = [
    libGL
    libx11
    libxcursor
    libxi
    libxkbcommon
    libxrandr
    wayland
  ];

  postInstall = ''
    install -m 444 -D "assets/images/icons/icon.png" "$out/share/icons/hicolor/256x256/apps/gupax.png"
    install -m 444 -D "assets/images/icons/icon@2x.png" "$out/share/icons/hicolor/1024x1024/apps/gupax.png"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gupax";
      desktopName = "Gupax";
      icon = "gupax";
      exec = finalAttrs.meta.mainProgram;
      comment = finalAttrs.meta.description;
      categories = [
        "Network"
        "Utility"
      ];
    })
  ];

  env = {
    # Needed to get openssl-sys to use pkg-config.
    OPENSSL_NO_VENDOR = 1;
    # Rust nightly
    RUSTC_BOOTSTRAP = 1;
    # cuprate-constants requires a SHA hash and git doesn't work here.
    # cuprate rev used: https://github.com/gupax-io/gupax/blob/main/Cargo.lock
    # build script: https://github.com/Cuprate/cuprate/blob/main/constants/build.rs
    GITHUB_SHA = "aa35ebdcb1a44dd11d778d50f6d32234c8802803";
  };

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GUI Uniting P2Pool And XMRig";
    homepage = "https://gupax.io";
    changelog = "https://github.com/hinto-janai/gupax/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "gupax";
    platforms = lib.platforms.linux;
  };
})
