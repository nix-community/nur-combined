{
  copyDesktopItems,
  cuprate,
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
  openssl,
  pkg-config,
  rustPlatform,
  wayland,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gupax";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "gupax-io";
    repo = "gupax";
    tag = "v${finalAttrs.version}";
    hash = "sha256-LEVJI3AWrr85g+X0Xt1uuvD1AtXB9UCHiacp4i0egP0=";
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
    copyDesktopItems
    git
    pkg-config
  ];

  buildInputs = [
    openssl
  ];

  postInstall = ''
    install -D assets/images/icons/icon.png $out/share/icons/hicolor/256x256/apps/gupax.png
    install -D assets/images/icons/icon@2x.png $out/share/icons/hicolor/1024x1024/apps/gupax.png
  '';

  postFixup = ''
    patchelf $out/bin/gupax --set-rpath ${
      lib.makeLibraryPath [
        libGL
        libx11
        libxcursor
        libxi
        libxkbcommon
        libxrandr
        wayland
      ]
    };
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gupax";
      desktopName = "Gupax";
      icon = "gupax";
      exec = "gupax";
      comment = "P2Pool and XMRig";
      categories = [ "Utility" ];
    })
  ];

  env = {
    # Needed to get openssl-sys to use pkg-config.
    OPENSSL_NO_VENDOR = 1;
    # Use Rust nightly.
    RUSTC_BOOTSTRAP = 1;
    # https://github.com/Cuprate/cuprate/blob/main/constants/build.rs
    GITHUB_SHA = cuprate.src.rev;
  };

  meta = {
    description = "GUI Uniting P2Pool And XMRig";
    homepage = "https://gupax.io";
    changelog = "https://github.com/hinto-janai/gupax/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "gupax";
    platforms = lib.platforms.linux;
  };
})
