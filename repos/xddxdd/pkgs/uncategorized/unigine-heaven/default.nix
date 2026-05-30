{
  sources,
  lib,
  stdenv,
  autoPatchelfHook,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  # Dependencies
  fontconfig,
  freetype,
  glib,
  libglvnd,
  openal,
  libICE,
  libSM,
  libX11,
  libXau,
  libxcb,
  libXcursor,
  libXdmcp,
  libXext,
  libXi,
  libXinerama,
  libXrandr,
  libXrender,
  zlib,
}:
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.unigine-heaven) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    copyDesktopItems
    makeWrapper
  ];
  buildInputs = [
    fontconfig
    freetype
    glib
    libglvnd
    openal
    stdenv.cc.cc.lib
    libICE
    libSM
    libX11
    libXau
    libxcb
    libXcursor
    libXdmcp
    libXext
    libXi
    libXinerama
    libXrandr
    libXrender
    zlib
  ];

  unpackPhase = ''
    runHook preUnpack

    sh "$src" --noexec --nox11 --target "$(pwd)"

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt
    cp -r * $out/opt/
    rm -f $out/opt/env-vars

    runHook postInstall
  '';

  postFixup = ''
    mkdir -p $out/bin
    makeWrapper $out/opt/heaven $out/bin/unigine-heaven \
      --chdir $out/opt \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath finalAttrs.buildInputs}"

    install -Dm644 $out/opt/data/launcher/icon.png $out/share/pixmaps/unigine-heaven.png
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "unigine-heaven";
      exec = "unigine-heaven";
      desktopName = "Unigine Heaven";
      genericName = finalAttrs.meta.description;
      icon = "unigine-heaven";
      categories = [
        "Game"
        "Utility"
      ];
      terminal = false;
    })
  ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Extreme performance and stability test for PC hardware: video card, power supply, cooling system";
    homepage = "https://benchmark.unigine.com/heaven";
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "unigine-heaven";
  };
})
