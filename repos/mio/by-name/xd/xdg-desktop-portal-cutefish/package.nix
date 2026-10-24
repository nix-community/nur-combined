{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  ninja,
  pkg-config,
  gettext,
  wayland-scanner,
  cutefish-toolkit,
  systemd,
  pipewire,
  wayland,
  wayland-protocols,
  mesa,
  libgbm,
  libdrm,
}:

let
  cu = import ../../cu/cutefish/mk.nix { inherit lib; };
in
stdenv.mkDerivation {
  pname = "xdg-desktop-portal-cutefish";
  version = cu.version "2026-10-20";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "xdg-desktop-portal-cutefish";
    rev = "03d019c0bf5cb875881f852b6a74e2b1670a5949";
    hash = "sha256-x9RvruXCTrSY7lbpLf6rrcwxLUsAM35Cd9Gjvgqf+64=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    pkg-config
    gettext
    wayland-scanner
  ];

  buildInputs = [
    cutefish-toolkit
    systemd
    pipewire
    wayland
    wayland-protocols
    mesa
    libgbm
    libdrm
  ];

  cmakeFlags = cu.cmakeFlags;

  meta = {
    inherit (cu) homepage platforms;
    description = "xdg-desktop-portal backend for the Cutefish desktop";
    license = lib.licenses.bsd3;
    mainProgram = "xdg-desktop-portal-cutefish";
  };
}
