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
  # testers,
  nix-update-script,
}:

stdenv.mkDerivation (_: {
  pname = "magpie-wayland";
  version = "0.9.4-unstable-2024-08-17";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "221970d1eef9140566da55481c8163725681289e";
    hash = "sha256-KjbjT60k2KrjY+X5oCRwucAvQM3H9wnn5i2v7LMd3dM=";
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

  passthru = {
    # Buddy thinks it's 1.0...
    # tests.version = testers.testVersion { package = finalAttrs.finalPackage; };

    updateScript = nix-update-script {
      extraArgs = [
        "--version"
        "branch=v1"
      ];
    };
  };

  meta = {
    mainProgram = "magpie-wm";
    description = "wlroots-based Wayland compositor designed for the Budgie Desktop";
    homepage = "https://github.com/BuddiesOfBudgie/magpie";
    license = lib.licenses.asl20;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder wlroots.version "0.18";
  };
})
