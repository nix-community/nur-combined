{
  pixman,
  ninja,
  scdoc,
  wayland-scanner,
  wlroots,
  xwayland,
  libxkbcommon,
  kdePackages, # This is not right but helpfully pulls in transitive deps
  waylandpp,
  wayland,
  pkg-config,
  cmake,
  fetchgit,
  lib,
  meson,
  stdenv,
}:

stdenv.mkDerivation {
  name = "wayback-x11";
  version = "0.0.1";

  src = fetchgit {
    url = "https://gitlab.freedesktop.org/wayback/wayback.git";
    rev = "195bcf74071fbb6866042650e466045ac62b087b";
    hash = "sha256-VYeX0Qmhr3U164gM/gyT82wIFmQxHxCygCPqPDctRcQ=";
  };

  buildInputs = [
    cmake
    meson
    pkg-config
    wayland
    waylandpp
    kdePackages.wayland-protocols
    libxkbcommon
    xwayland
    wlroots
    wayland-scanner
    scdoc
    ninja
    pixman
  ];
  #nativeBuildInputs = [ ninja ];
  dontUseCmakeConfigure = true;
  #buildPhase = ''
  #  meson install
  #'';
}
