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
  version = "unstable-2023-10-20";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "e26dfa8d241a183c2280d4a65851bbe869f3e5f2";
    hash = "sha256-KbHXnuGSuFEjXi5S5D/BiN+FxEAGemj3Jf4LXMX+5ZE=";
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
