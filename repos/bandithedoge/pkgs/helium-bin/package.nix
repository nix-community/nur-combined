{
  sources,

  lib,
  stdenv,

  alsa-lib,
  at-spi2-atk,
  autoPatchelfHook,
  cups,
  expat,
  gtk4,
  libGL,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  makeWrapper,
  nspr,
  nss,
  pipewire,
  qt6,
  systemd,

  commandLineArgs ? "",
}:
let
  source = if stdenv.isAarch64 then sources.helium-bin-arm64 else sources.helium-bin-x86_64;
in
stdenv.mkDerivation {
  pname = "helium-bin";
  inherit (source) version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    cups
    expat
    gtk4
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    qt6.qtbase
    qt6.qtwayland
    stdenv.cc.cc.lib
    systemd
  ];

  autoPatchelfIgnoreMissingDeps = [ "libQt5*.so.5" ];

  dontWrapQtApps = true;

  buildPhase = ''
    runHook preBuild

    mkdir -p $out/{bin,libexec/helium,share/applications,share/icons/hicolor/256x256/apps}
    cp -r * $out/libexec/helium

    makeWrapper $out/libexec/helium/helium $out/bin/helium \
      --add-flags ${lib.escapeShellArg commandLineArgs} \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          gtk4
          libGL
          pipewire
        ]
      }

    patchelf --add-needed libEGL.so.1 $out/libexec/helium/lib*GL*
    rm $out/libexec/helium/libvulkan.so.1
    patchelf --add-needed libvulkan.so.1 $out/libexec/helium/lib*GL*

    ln -s $out/libexec/helium/helium.desktop $out/share/applications
    ln -s $out/libexec/helium/product_logo_256.png $out/share/icons/hicolor/256x256/apps/helium.png

    runHook postBuild
  '';

  meta = {
    description = "Private, fast, and honest web browser";
    homepage = "https://helium.computer/";
    license = with lib.licenses; [
      gpl3Plus
      bsd3
    ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "helium";
    maintainers = [ lib.maintainers.bandithedoge ];
  };
}
