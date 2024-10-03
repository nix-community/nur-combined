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
  xorg,
  zlib,
}:
stdenv.mkDerivation rec {
  inherit (sources.unigine-tropics) pname version src;

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
    mkdir -p $out/opt/bin/Tropics0
    makeWrapper $out/opt/bin/Tropics $out/bin/unigine-tropics \
      --chdir $out/opt \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath buildInputs}" \
      --add-flags "-system_script" \
      --add-flags "tropics/unigine.cpp" \
      --add-flags "-engine_config" \
      --add-flags "$out/opt/data/unigine.cfg" \
      --add-flags "-data_path" \
      --add-flags "../../"
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "unigine-tropics";
      exec = "unigine-tropics";
      desktopName = "Unigine Tropics";
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
    homepage = "https://benchmark.unigine.com/tropics";
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
    license = licenses.unfree;
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
