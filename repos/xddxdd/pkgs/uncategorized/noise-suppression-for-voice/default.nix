{
  stdenv,
  sources,
  lib,
  cmake,
  pkg-config,
  alsa-lib,
  # Dependencies
  at-spi2-core,
  curl,
  dbus,
  freetype,
  gtk3-x11,
  libdatrie,
  libepoxy,
  libpsl,
  libselinux,
  libsepol,
  libsysprof-capture,
  libthai,
  libxkbcommon,
  pcre,
  sqlite,
  util-linux,
  vtk,
  webkitgtk_4_0,
  xorg,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.noise-suppression-for-voice) pname version src;
  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    alsa-lib
    at-spi2-core
    curl
    dbus
    freetype
    gtk3-x11
    libdatrie
    libepoxy
    libpsl
    libselinux
    libsepol
    libsysprof-capture
    libthai
    libxkbcommon
    pcre
    sqlite
    util-linux
    vtk
    webkitgtk_4_0
    xorg.libX11
    xorg.libXcursor
    xorg.libXdmcp
    xorg.libXext
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXtst
  ];

  meta = {
    changelog = "https://github.com/werman/noise-suppression-for-voice/releases/tag/v${finalAttrs.version}";
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Noise suppression plugin based on Xiph's RNNoise";
    homepage = "https://github.com/werman/noise-suppression-for-voice";
    license = lib.licenses.gpl3Only;
  };
})
