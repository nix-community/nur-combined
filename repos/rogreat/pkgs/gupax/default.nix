{
  copyDesktopItems,
  cuprate,
  dbus,
  fetchFromGitHub,
  lib,
  libglvnd,
  libx11,
  libxcursor,
  libxi,
  libxkbcommon,
  libxrender,
  makeDesktopItem,
  monero-cli,
  p2pool,
  rustPlatform,
  vulkan-loader,
  wayland,
  xmrig,
  xmrig-proxy,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gupax";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "gupax-io";
    repo = "gupax";
    rev = "bb5827eb19d6494d1edb6eba7a991e71fd396f5e";
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

  preBuild = ''
    rm build.rs
  '';

  nativeBuildInputs = [
    copyDesktopItems
  ];

  postInstall = ''
    mkdir $out/bin/{node,p2pool,xmrig,xmrig-proxy}
    ln -s ${lib.getExe' monero-cli "monerod"} $out/bin/node
    ln -s ${lib.getExe p2pool} $out/bin/p2pool
    ln -s ${lib.getExe xmrig} $out/bin/xmrig
    ln -s ${lib.getExe xmrig-proxy} $out/bin/xmrig-proxy

    install -D assets/images/icons/icon.png $out/share/icons/hicolor/256x256/apps/gupax.png
    install -D assets/images/icons/icon@2x.png $out/share/icons/hicolor/1024x1024/apps/gupax.png
  '';

  postFixup = ''
    patchelf $out/bin/gupax --set-rpath ${
      lib.makeLibraryPath [
        dbus # libdbus-1.so
        libglvnd # libGL.so libEGL.so
        libx11 # libX11.so libX11-xcb.so
        libxcursor # libXcursor.so
        libxi # libXi.so
        libxkbcommon # libxkbcommon.so libxkbcommon-x11.so
        libxrender # libXrender.so
        vulkan-loader # libvulkan.so
        wayland # libwayland-egl.so libwayland-client.so
      ]
    };
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "gupax";
      desktopName = "Gupax";
      genericName = "Miner";
      comment = "GUI Uniting P2Pool And XMRig";
      icon = "gupax";
      exec = "gupax";
      categories = [
        "Network"
        "Utility"
      ];
    })
  ];

  env = {
    # https://doc.rust-lang.org/beta/unstable-book/compiler-environment-variables/RUSTC_BOOTSTRAP.html
    RUSTC_BOOTSTRAP = 1;
    # https://github.com/gupax-io/gupax/blob/main/build.rs
    COMMIT = finalAttrs.src.rev;
    # https://github.com/Cuprate/cuprate/blob/main/constants/build.rs
    GITHUB_SHA = cuprate.src.rev;
  };

  meta = {
    description = "GUI Uniting P2Pool And XMRig";
    homepage = "https://gupax.io";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "gupax";
    platforms = lib.platforms.linux;
  };
})
