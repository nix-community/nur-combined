{
  lib,
  stdenv,
  fetchgit,
  meson,
  ninja,
  pkg-config,
  wayland-scanner,
  wayland,
  wayland-protocols,
  kylin-wlroots,
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
}:

stdenv.mkDerivation rec {
  pname = "kylin-wayland-compositor";
  version = "1.3.0-ok46";

  src = fetchgit {
    url = "https://gitee.com/openKylin/kylin-wayland-compositor.git";
    rev = "0189d50266741af433f41ad4fb0b16d274ae2b54";
    hash = "sha256-iQgill8WbFM02eSd9cmfzlUoil4GOdZnbZeKBslPeXo=";
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
    kylin-wlroots
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
  ];

  meta = {
    description = "kylin wayland compositor based on wlroots";
    homepage = "https://gitee.com/openkylin/kylin-wayland-compositor";
    license = lib.licenses.gpl1Plus;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
}
