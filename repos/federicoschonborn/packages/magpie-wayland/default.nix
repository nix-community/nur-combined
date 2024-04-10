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
  version = "unstable-2024-04-08";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "a1fb21f6f6f1bec4e259cd9aacc632e2bc7d73fc";
    hash = "sha256-6pl47ReE4U62N6FVZqMjliGa8Qmik9952N0rZ/RLMro=";
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
