{
  stdenv,
  makeBinaryWrapper,
  lib,
  libsForQt5,
  gepetto-viewer-base,
  gepetto-viewer-corba,
  hpp-gepetto-viewer,
  hpp-gui,
  hpp-plot,
}:
stdenv.mkDerivation {
  inherit (gepetto-viewer-base) pname version meta;
  buildInputs = [ makeBinaryWrapper ];
  #propagatedBuildInputs = [ corba ];
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    makeBinaryWrapper ${lib.getExe gepetto-viewer-base} $out/bin/gepetto-gui \
      --set GEPETTO_GUI_PLUGIN_DIRS ${gepetto-viewer-corba}/lib:${hpp-gepetto-viewer}/lib:${hpp-plot}/lib:${hpp-gui}/lib \
      --set QP_QPA_PLATFORM_PLUGIN_PATH ${libsForQt5.qtbase.bin}/lib/qt-${libsForQt5.qtbase.version}/plugins \
      --set QT_QPA_PLATFORM xcb
  '';
}
