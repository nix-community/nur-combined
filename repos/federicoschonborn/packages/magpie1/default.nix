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
  pname = "magpie1";
  version = "unstable-2024-01-29";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "038e4416c4581ef046eb6fb9149cdf8dc6e6f4ef";
    hash = "sha256-JqCvM+Pa8XQV6/cZ8f7ugatVkUd1iZXaWKVFczU6SFM=";
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

  passthru.updateScript = unstableGitUpdater {branch = "v1";};

  meta = {
    mainProgram = "magpie-wm";
    description = "wlroots-based Wayland compositor designed for the Budgie Desktop";
    homepage = "https://github.com/BuddiesOfBudgie/magpie";
    branch = "v1";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [federicoschonborn];
  };
}
