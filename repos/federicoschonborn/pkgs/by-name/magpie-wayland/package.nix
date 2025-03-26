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
  version = "0.9.4-unstable-2025-03-25";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "a9cfac5a381968741dd27a5e3f971af8fe3126c7";
    hash = "sha256-TDg163p/bCY+9DvYu000JofckBfUSuoblvmodeIu93w=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    argparse
    libxkbcommon
    pixman
    udev
    wayland
    wayland-protocols
    wayland-scanner
    wlroots_0_18
    xorg.libxcb
    xorg.xcbutilwm
  ];

  nativeInstallCheckInputs = [ versionCheckHook ];
  doInstallCheck = true;

  versionCheckProgram = "${placeholder "out"}/bin/magpie-wm";
  # Does not have a proper version yet.
  dontVersionCheck = true;

  strictDeps = true;

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
