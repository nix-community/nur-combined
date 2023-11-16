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
  version = "unstable-2023-11-12";

  src = fetchFromGitHub {
    owner = "BuddiesOfBudgie";
    repo = "magpie";
    rev = "c7cf1b062547691944add8a0fc9166fb378d4f9e";
    hash = "sha256-+NhvxiriuLCYHJyc02KvOoGQ2Ecen3dwiwOADIpQoZE=";
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
