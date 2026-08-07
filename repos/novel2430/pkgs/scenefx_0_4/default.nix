{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  cmake,
  wayland-scanner,
  glslang,
  pixman,
  wayland,
  wayland-protocols,
  wlroots_0_19,
  libdrm,
  libgbm,
  libGL,
  libxkbcommon,
  libxcb,
  xcbutilwm,
}:
stdenv.mkDerivation rec {
  pname = "scenefx";
  version = "0.4.1";

  src = fetchFromGitHub {
    owner = "wlrfx";
    repo = "scenefx";
    tag = version;
    hash = "sha256-XD5EcquaHBg5spsN06fPHAjVCb1vOMM7oxmjZZ/PxIE=";
  };

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    cmake
    wayland-scanner
    glslang
  ];

  buildInputs = [
    pixman
    wayland
    wayland-protocols
    wlroots_0_19
    libdrm
    libgbm
    libGL
    libxkbcommon
    libxcb
    xcbutilwm
  ];

  meta = {
    description = "Drop-in replacement for the wlroots scene API with eye-candy effects";
    homepage = "https://github.com/wlrfx/scenefx";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
  };
}
