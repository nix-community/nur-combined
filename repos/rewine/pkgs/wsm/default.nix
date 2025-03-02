{
  lib,
  stdenv,
  fetchFromGitHub,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  wayland,
  wayland-protocols,
  wlroots,
  xorg,
  libxkbcommon,
  libdrm,
  libGL,
  libinput,
  pixman,
  json_c,
  cairo,
  pango,
  librsvg,
  libepoxy,
  libunwind,
  mesa,
  cglm,
  openssl,
  vulkan-headers,
  libXpm,
  libxml2,
}:

stdenv.mkDerivation rec {
  pname = "wsm";
  version = "0-unstable-2025-01-01";

  src = fetchFromGitHub{
    owner = "zzxyb";
    repo = "wsm";
    rev = "5b3003b6ecf21bd7e193546d42810d34df6c09d4";
    hash = "sha256-admtM3r/HJNByhTQPsD1up4wben59qmeZ7J4gv5bYkY=";
  };

  postPatch = ''
    for file in $(grep -rl "/usr")
    do
      substituteInPlace $file \
        --replace "/usr" "$out"
    done
    for file in $(grep -rl "/etc")
    do
      substituteInPlace $file \
        --replace "/etc" "$out/etc"
    done
  '';

  depsBuildBuild = [ pkg-config ];

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    wayland
    wayland-protocols
    wlroots
    xorg.libX11
    xorg.xcbutilwm
    libxkbcommon
    libdrm
    libGL
    libinput
    pixman
    json_c
    cairo
    pango
    librsvg
    libepoxy
    libunwind
    mesa
    cglm
    openssl
    vulkan-headers
    libXpm
    libxml2
  ];

  meta = {
    description = "lychee wayland surface manager for pc and mobile devices";
    homepage = "https://github.com/zzxyb/wsm";
    license = lib.licenses.gpl1Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ rewine ];
  };
}
