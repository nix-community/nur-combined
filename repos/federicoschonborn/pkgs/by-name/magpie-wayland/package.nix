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
  wlroots,
  xorg,
  versionCheckHook,
  nix-update-script,
}:

stdenv.mkDerivation (_: {
  pname = "magpie-wayland";
  version = "0.9.4-unstable-2024-12-14";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "ed028034f5fb7de56c5b2b618425f0a2ff2994c1";
    hash = "sha256-upPjTJCU8g38XzlbrHvDy7JEIrhMNIdAuF+R5NU02lk=";
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
    wlroots
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
