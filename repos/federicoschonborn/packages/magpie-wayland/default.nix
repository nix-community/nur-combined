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
  unstableGitUpdater,
}:

stdenv.mkDerivation {
  pname = "magpie-wayland";
  version = "unstable-2024-03-10";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "3f14a193abf54903678fe4a2bcebbcd29fda5d84";
    hash = "sha256-lKPH/UiSLRHNUm+sXb1CMUDotxvlHnmJYxqbALoCijU=";
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

  passthru.updateScript = unstableGitUpdater { branch = "v1"; };

  meta = {
    mainProgram = "magpie-wm";
    description = "wlroots-based Wayland compositor designed for the Budgie Desktop";
    homepage = "https://github.com/BuddiesOfBudgie/magpie";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
  };
}
