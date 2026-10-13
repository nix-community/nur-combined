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
  libxcursor,
  libxrandr,
  makeWrapper,
  ncurses,
  qt5,
  readline,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mod-desktop-bin";
  version = "0.0.13";
  src = fetchzip {
    url = "https://github.com/mod-audio/mod-desktop/releases/download/${finalAttrs.version}/mod-desktop-${finalAttrs.version}-linux-x86_64.tar.xz";
    sha256 = "sha256-OLHj3aX8tF/ibYvEKC0OCFHeHdNqpEvYtimXFT+y80k=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    dbus
    glib
    libuuid
    libxcursor
    libxrandr
    ncurses
    qt5.qtbase
    readline
    stdenv.cc.cc.lib
  ];

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/libexec
    cp -r * $out/libexec

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,lib/clap,lib/lv2,lib/vst3,lib/vst}

    makeWrapper $out/libexec/mod-desktop/mod-desktop $out/bin/mod-desktop \
      --chdir "$out/libexec/mod-desktop"

    ln -s $out/libexec/plugin-variants/mod-desktop.clap $out/lib/clap
    ln -s $out/libexec/plugin-variants/mod-desktop.lv2 $out/lib/lv2
    ln -s $out/libexec/plugin-variants/mod-desktop.vst3 $out/lib/vst3
    ln -s $out/libexec/plugin-variants/mod-desktop-vst.so $out/lib/vst

    runHook postInstall
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
