{
  fetchzip,
  lib,
  nix-update-script,
  stdenv,

  alsa-lib,
  autoPatchelfHook,
  dbus,
  glib,
  libuuid,
  qt5,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mod-desktop-bin";
  version = "0.0.12";
  src = fetchzip {
    url = "https://github.com/mod-audio/mod-desktop/releases/download/${finalAttrs.version}/mod-desktop-${finalAttrs.version}-linux-x86_64.tar.xz";
    sha256 = "sha256-MXGVgjjWuBy0bX528asX6pbR7ptQTHQy4Zd/GVgtQyo=";
  };

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

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "MOD Audio for the desktop";
    homepage = "https://mod.audio/desktop/";
    license = lib.licenses.agpl3Plus;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = [ lib.maintainers.bandithedoge ];
  };
})
