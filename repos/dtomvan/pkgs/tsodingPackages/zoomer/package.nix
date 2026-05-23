{
  lib,
  stdenv,
  fetchFromGitea,
  zig_0_15,

  egl-wayland,
  egl-x11,
  libglvnd,
  libx11,
  libxcomposite,
  libxext,
  libxrandr,
  wayland,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zoomer";
  version = "0-unstable-2026-05-23";

  src = fetchFromGitea {
    domain = "codeberg.org";
    owner = "imal";
    repo = "zoomer";
    rev = "34db6ed641d06f4947521bbd80cdd56cce208c65";
    hash = "sha256-s9mhmfnZZkNgj9qPiVc8L6191NTkrje3nL6RJ2/Y6v0=";
  };

  postPatch = ''
    sed -i -e '/installArtifact(exe);$/i \ exe.linkLibC();' build.zig
  '';

  nativeBuildInputs = [
    zig_0_15
  ];

  buildInputs = [
    stdenv.cc.cc.libc_dev
    egl-wayland
    egl-x11
    libglvnd
    libx11
    libxcomposite
    libxext
    libxrandr
    wayland
  ];

  meta = {
    description = "Zoomer a boomer application for Linux";
    homepage = "https://codeberg.org/imal/zoomer";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dtomvan ];
    mainProgram = "zoomer";
    platforms = lib.platforms.linux;
  };
})
