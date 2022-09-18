{ stdenv
, sources
, lib
, cmake
, pkgconfig
, alsa-lib
  # Dependencies
, at-spi2-core
, curl
, dbus
, freetype
, gtk3-x11
, libdatrie
, libepoxy
, libpsl
, libselinux
, libsepol
, libsysprof-capture
, libthai
, libxkbcommon
, pcre
, sqlite
, util-linux
, vtk
, webkitgtk
, xorg
, ...
}:

stdenv.mkDerivation rec {
  inherit (sources.noise-suppression-for-voice) pname version src;
  nativeBuildInputs = [ cmake pkgconfig ];
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
    webkitgtk
    xorg.libX11
    xorg.libXcursor
    xorg.libXdmcp
    xorg.libXext
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXtst
  ];

  meta = with lib; {
    description = "Noise suppression plugin based on Xiph's RNNoise";
    homepage = "https://github.com/werman/noise-suppression-for-voice";
    license = licenses.gpl3;
  };
}
