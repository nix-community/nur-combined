{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  wayland,
  argparse,
  libxkbcommon,
  pixman,
  udev,
  wayland-protocols,
  wlroots,
  xorg,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "magpie-wayland";
  version = "0.9.3-unstable-2024-07-14";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "0c658db5616633cd90c02624e5ce6c0f75428919";
    hash = "sha256-xx1nJna+AJtggvAi7j8mdRW/WGA/636S1t80rNEpQLg=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland # wayland-scanner
  ];

  buildInputs = [
    argparse
    libxkbcommon
    pixman
    udev
    wayland-protocols
    wlroots
    xorg.libxcb
    xorg.xcbutilwm
  ];

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
    badPlatforms = lib.platforms.darwin;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder wlroots.version "0.18";
  };
}
