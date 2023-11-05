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
  version = "unstable-2023-11-04";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "249afac008f19d51f1764d7a576a17dbc487a1e7";
    hash = "sha256-Z/XTARZeZ9R25e3kofJ7Wg1iTm2YogoKPKdZIHVG0d0=";
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
