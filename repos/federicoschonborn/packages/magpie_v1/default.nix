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
  version = "unstable-2023-10-22";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "f81b8f858dfada554d1d3a27966ba20e564420ef";
    hash = "sha256-nbY9pSr0ollVvC8F2vnRrIRN0jJvj8hfo5DgxsvSQO0=";
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
