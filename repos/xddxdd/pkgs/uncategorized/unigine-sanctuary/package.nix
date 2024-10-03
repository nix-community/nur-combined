{
  sources,
  lib,
  stdenv,
  autoPatchelfHook,
  buildFHSEnv,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
  # Dependencies
  fontconfig,
  freetype,
  glib,
  glxinfo,
  libglvnd,
  openal,
  xorg,
  zlib,
}:
stdenv.mkDerivation rec {
  inherit (sources.unigine-sanctuary) pname version src;

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
    xorg.libICE
    xorg.libSM
    xorg.libX11
    xorg.libXau
    xorg.libxcb
    xorg.libXcursor
    xorg.libXdmcp
    xorg.libXext
    xorg.libXi
    xorg.libXinerama
    xorg.libXrandr
    xorg.libXrender
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
    makeWrapper $out/opt/bin/Sanctuary $out/bin/unigine-sanctuary \
      --chdir $out/opt \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --add-flags "-system_script" \
      --add-flags "sanctuary/unigine.cpp" \
      --add-flags "-engine_config" \
      --add-flags "$out/opt/data/unigine.cfg" \
      --add-flags "-data_path" \
      --add-flags "../"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "unigine-sanctuary";
      exec = "unigine-sanctuary";
      desktopName = "Unigine Sanctuary";
      genericName = meta.description;
      categories = [
        "Game"
        "Utility"
      ];
      terminal = false;
    })
  ];

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Extreme performance and stability test for PC hardware: video card, power supply, cooling system.";
    homepage = "https://benchmark.unigine.com/sanctuary";
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
