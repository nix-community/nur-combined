{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  qt6,
  jsoncpp,
  libupnpp,
  libupnp,
}:

stdenv.mkDerivation rec {
  pname = "upplay";
  version = "1.9.9";

  src = fetchurl {
    url = "https://www.lesbonscomptes.com/${pname}/downloads/${pname}-${version}.tar.gz";
    hash = "sha256-PJHRpCL4+HXSbmyiia0jaKMb5Fr60CWjm9WSsbGh1o4=";
  };

  nativeBuildInputs = [
    pkg-config
    qt6.qttools # moc, lrelease, etc.
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwebengine
    qt6.qtwebchannel
    jsoncpp
    libupnpp
    libupnp
  ];

  # We don't need any of Qt's wrapping here (no qtWrapperArgs etc.)
  dontWrapQtApps = true;

  postPatch = ''
    # Disable Qt5 MPRIS support (comment out the mpris-qt5 config)
    substituteInPlace upplay.pro \
      --replace-warn "    CONFIG +=  mpris-qt5" "    # CONFIG +=  mpris-qt5 (disabled in Nix build)" \
      --replace-warn "    DEFINES += HAVE_QTMPRIS" "    # DEFINES += HAVE_QTMPRIS (disabled in Nix build)"

    # Remove the Qt6 amber-mpris block entirely (no bundled MPRIS)
    sed -i '/# Use local qtmpris version for qt6 as it is not generally packaged yet\./,/^  isEmpty(PREFIX) {/{/^  isEmpty(PREFIX) {/!d}' upplay.pro
  '';

  configurePhase = ''
    qmake upplay.pro
  '';

  buildPhase = "make";

  installPhase = ''
    make install INSTALL_ROOT=$out

    # Normalize layout: move binary to $out/bin so profiles pick it up
    mkdir -p $out/bin
    if [ -x "$out/usr/bin/upplay" ]; then
      mv "$out/usr/bin/upplay" "$out/bin/"
    fi
  '';

  meta = with lib; {
    description = "Qt-based UPnP/OpenHome audio control point";
    homepage = "https://www.lesbonscomptes.com/upplay/";
    license = licenses.gpl2Plus;
    sourceProvenance = with sourceTypes; [ fromSource ];
    platforms = platforms.linux;
    mainProgram = "upplay";
  };
}
