{
  autoPatchelfHook,
  fetchFromGitHub,
  git,
  lib,
  libGL,
  libxkbcommon,
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
    hash = "sha256-IOONLurL6DjSqlej5qzpgxsVJZE/zYojPTO+AKuzSoQ=";
    leaveDotGit = true; # git command in build.rs
  };

  cargoHash = "sha256-PILtRjQ8Vt20ObFhsb4qBoC8VEqHPshZvjLxqtfpj9Y=";

  checkFlags = [
    # requires filesystem write
    "--skip disk::test::create_and_serde_gupax_p2pool_api"
  ];

  nativeBuildInputs = [
    autoPatchelfHook
    git
    pkg-config
  ];

  buildInputs = [
    openssl
    stdenv.cc.cc.libgcc or null # libgcc_s.so
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

  # Needed to get openssl-sys to use pkg-config.
  OPENSSL_NO_VENDOR = 1;

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "GUI Uniting P2Pool And XMRig";
    homepage = "https://gupax.io";
    changelog = "https://github.com/hinto-janai/gupax/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ RoGreat ];
    mainProgram = "gupax";
    platforms = lib.platforms.linux;
  };
})
