{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  argparse,
  libxkbcommon,
  pixman,
  udev,
  wayland,
  wayland-protocols,
  wlroots_0_18,
  xorg,
  versionCheckHook,
  nix-update-script,
}:

stdenv.mkDerivation (_: {
  pname = "magpie-wayland";
  version = "0.9.4-unstable-2024-12-18";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "9eb256ed94a8e816c7f7edbd5b440660e8fe4ce4";
    hash = "sha256-G3nlcTKjdgzMW6u9Zw1nTrr7thGBjhrNKrcuIXR/yHs=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    argparse
    libxkbcommon
    pixman
    udev
    wayland
    wayland-protocols
    wlroots_0_18
    xorg.libxcb
    xorg.xcbutilwm
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];

  doInstallCheck = true;
  versionCheckProgram = "${placeholder "out"}/bin/magpie-wm";
  dontVersionCheck = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch=v1"
    ];
  };

  meta = {
    mainProgram = "magpie-wm";
    description = "wlroots-based Wayland compositor designed for the Budgie Desktop";
    homepage = "https://github.com/BuddiesOfBudgie/magpie";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
})
