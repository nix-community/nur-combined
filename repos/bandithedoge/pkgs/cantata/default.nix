{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.cantata) pname version src;

  nativeBuildInputs = with pkgs; [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
    qt6.qttools
  ];

  buildInputs = with pkgs; [
    avahi
    cdparanoia
    ffmpeg
    libmtp
    libmusicbrainz5
    mpg123
    qt6.qtbase
    qt6.qtmultimedia
    qt6.qtsvg
    speex
    taglib
    taglib_extras
    udisks2
  ];

  meta = with pkgs.lib; {
    description = "Qt Graphical MPD Client (nullobsi fork)";
    homepage = "https://github.com/nullobsi/cantata";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
