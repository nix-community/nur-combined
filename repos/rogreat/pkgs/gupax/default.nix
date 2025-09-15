{
  autoPatchelfHook,
  copyDesktopItems,
  fetchFromGitHub,
  git,
  lib,
  libGL,
  libxkbcommon,
  makeDesktopItem,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  wayland,
  xorg,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gupax";
  version = "1.3.11";

  src = fetchFromGitHub {
    owner = "hinto-janai";
    repo = "gupax";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Ix7TEJmhbTRKJvDkv83fRJ6um3cbhpwgHv5c6SehEPk=";
    leaveDotGit = true; # build.rs uses git
  };

  cargoHash = "sha256-PILtRjQ8Vt20ObFhsb4qBoC8VEqHPshZvjLxqtfpj9Y=";

  checkFlags = [
    # Test requires filesystem write outside of sandbox.
    "--skip disk::test::create_and_serde_gupax_p2pool_api"
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
    libxkbcommon
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
  ];

  postInstall = ''
    install -m 444 -D "images/icons/icon.png" "$out/share/icons/hicolor/256x256/apps/gupax.png"
    install -m 444 -D "images/icons/icon@2x.png" "$out/share/icons/hicolor/1024x1024/apps/gupax.png"
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

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;

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
