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
  systemd,
  wayland-protocols,
  wlroots_0_17,
  xorg,
  nix-update-script,
}:

stdenv.mkDerivation {
  pname = "magpie-wayland";
  version = "0.9.3-unstable-2024-07-07";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "271ef83cebe597c405583287c724cab78dea0b81";
    hash = "sha256-PcjMDU9en4eLC/Nq5XRuiV1ROEvPeLv8L+96u6tmCGg=";
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
    systemd
    wayland-protocols
    wlroots_0_17
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
    maintainers = [ lib.maintainers.federicoschonborn ];
  };
}
