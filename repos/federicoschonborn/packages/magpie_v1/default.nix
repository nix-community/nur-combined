{ lib
, stdenv
, fetchFromGitHub
, meson
, ninja
, pkg-config
, wayland
, libxkbcommon
, pixman
, systemd
, wayland-protocols
, wlroots
, xorg
, unstableGitUpdater
}:

stdenv.mkDerivation {
  pname = "magpie_v1";
  version = "unstable-2023-10-29";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "c8a0e7f8e4b900487e37fe36fed9e74bc3367881";
    hash = "sha256-c1YE2DfWedpUymBSlNDlcMBg2dlisIdI4akfEXIy2UA=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland # wayland-scanner
  ];

  buildInputs = [
    libxkbcommon
    pixman
    systemd
    wayland-protocols
    wlroots
    xorg.libxcb
    xorg.xcbutilwm
  ];

  passthru.updateScript = unstableGitUpdater { branch = "v1"; };

  meta = {
    mainProgram = "magpie-wm";
    description = "wlroots-based Wayland compositor designed for the Budgie Desktop";
    homepage = "https://github.com/BuddiesOfBudgie/magpie";
    branch = "v1";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ federicoschonborn ];
    broken = lib.versionOlder wlroots.version "0.16";
  };
}
