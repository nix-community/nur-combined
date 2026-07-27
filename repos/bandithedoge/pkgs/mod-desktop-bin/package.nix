{
  sources,

  lib,
  stdenv,

  alsa-lib,
  autoPatchelfHook,
  dbus,
  glib,
  libuuid,
  qt5,
}:
stdenv.mkDerivation {
  inherit (sources.mod-desktop-bin) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    alsa-lib
    dbus
    glib
    libuuid
    qt5.qtbase
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/libexec
    cp -r * $out/libexec

    runHook postBuild
  '';

  dontWrapQtApps = true;

  meta = {
    description = "MOD Audio for the desktop";
    homepage = "https://mod.audio/desktop/";
    license = lib.licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
