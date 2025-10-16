{
  lib,
  stdenv,
  sources,
  cmake,
  pkg-config,
  # Depedencies
  alsa-lib,
  at-spi2-atk,
  cairo,
  cups,
  expat,
  fontconfig,
  gdk-pixbuf,
  glib,
  gnome2,
  gtk2,
  libpulseaudio,
  nspr,
  nss,
  pango,
  python312,
  qt5,
  xorg,
}:
let
  libraries = [
    alsa-lib
    at-spi2-atk
    cairo
    cups
    expat
    fontconfig
    gdk-pixbuf
    glib
    gnome2.GConf
    gtk2
    libpulseaudio
    nspr
    nss
    pango
    xorg.libXcomposite
    xorg.libXcursor
    xorg.libXdamage
    xorg.libXext
    xorg.libXfixes
    xorg.libXi
    xorg.libXrandr
    xorg.libXrender
    xorg.libXScrnSaver
    xorg.libXtst
  ];

  rpaths = lib.concatMapStringsSep " " (l: "-Wl,-rpath,${lib.getOutput "lib" l}/lib") libraries;
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.libqcef) pname version src;

  patches = [ ./fix-deprecated-option.patch ];

  nativeBuildInputs = [
    cmake
    pkg-config
  ];
  buildInputs = [
    qt5.qtbase
    qt5.qtwebengine
    qt5.qtx11extras
  ];

  cmakeFlags = [
    "-DCMAKE_BUILD_TYPE=Release"
    "-DCMAKE_POLICY_VERSION_MINIMUM=3.5"
  ];

  env.CFLAGS = "-Wno-error=template-id-cdtor";
  env.CXXFLAGS = "-Wno-error=template-id-cdtor";

  dontWrapQtApps = true;

  preConfigure = ''
    rm -rf cef
    ln -sf ${sources.cef-binary.src} cef

    sed -i 's|-Wall|${rpaths}|g' src/CMakeLists.txt
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Qt5 binding of CEF";
    homepage = "https://github.com/martyr-deepin/libqcef";
    platforms = [ "x86_64-linux" ];
    license = lib.licenses.lgpl3Only;
  };
})
