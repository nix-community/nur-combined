# # adapted from upstream https://github.com/noctalia-dev/noctalia-greeter/blob/main/nix/package.nix
{
  lib,
  stdenv,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  wayland,
  wayland-protocols,
  wlroots_0_20,
  libGL,
  libglvnd,
  freetype,
  fontconfig,
  cairo,
  pango,
  harfbuzz,
  libxkbcommon,
  libwebp,
  glib,
  librsvg,
  jemalloc,
  fetchFromGitHub,
}:

stdenv.mkDerivation {
  pname = "noctalia-greeter";
  version = "0-unstable-2026-07-01";

  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia-greeter";
    rev = "c09a6b5067ab104d6a47fa404ab4ef1f423c3f4c";
    hash = "sha256-1skV92jfsKq3eAJocomduPABTPcHcZHX8bDBNGm65VU=";
  };

  postPatch = ''
    # Remove -march=native and -mtune=native for reproducible builds
    sed -i "s/'-march=native', '-mtune=native',//" meson.build
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
    jemalloc
  ];

  buildInputs = [
    wayland
    wayland-protocols
    wlroots_0_20
    libGL
    libglvnd
    freetype
    fontconfig
    cairo
    pango
    harfbuzz
    libxkbcommon
    libwebp
    glib
    librsvg
  ];

  mesonBuildType = "release";

  ninjaFlags = [ "-v" ];

  meta = with lib; {
    description = "Noctalia Greeter - A minimal login greeter for greetd that matches the look and feel of Noctalia Shell";
    homepage = "https://github.com/noctalia-dev/noctalia-greeter";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "noctalia-greeter";
  };
}
