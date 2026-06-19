{
  lib,
  config,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  wayland,
  wayland-protocols,
  libGL,
  libglvnd,
  freetype,
  fontconfig,
  cairo,
  pango,
  harfbuzz,
  libxkbcommon,
  sdbus-cpp_2,
  systemd,
  pipewire,
  pam,
  curl,
  libwebp,
  glib,
  polkit,
  librsvg,
  libqalculate,
  libxml2,
  jemalloc,
  autoAddDriverRunpath,
  cudaSupport ? config.cudaSupport,
}:
let
  version = "5.0.0";
in
stdenv.mkDerivation {
  pname = "noctalia";
  inherit version;

  src = fetchFromGitHub {
    owner = "noctalia-dev";
    repo = "noctalia";
    rev = "d6e55dce0f8143dec17025bcc61f1aea33e10dfe";
    hash = "sha256-AXSVg1/DNTl4vAKUSh8lgmupBLHP5vrCNW09WakOwTQ=";
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
  ]
  ++ lib.optional cudaSupport autoAddDriverRunpath;

  buildInputs = [
    wayland
    wayland-protocols
    libGL
    libglvnd
    freetype
    fontconfig
    cairo
    pango
    harfbuzz
    libxkbcommon
    sdbus-cpp_2
    systemd
    pipewire
    pam
    curl
    libwebp
    glib
    polkit
    librsvg
    libqalculate
    libxml2
  ];

  mesonBuildType = "release";

  ninjaFlags = [ "-v" ];

  meta = with lib; {
    description = "A lightweight Wayland shell and bar built directly on Wayland + OpenGL ES";
    homepage = "https://github.com/noctalia-dev/noctalia-shell";
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "noctalia";
  };
}
