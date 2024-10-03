{
  sources,
  lib,
  stdenv,
  pkgsi686Linux,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
}:
let
  libraries = with pkgsi686Linux; [
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

  distPackage = pkgsi686Linux.stdenv.mkDerivation {
    inherit (sources.unigine-tropics) pname version src;

    nativeBuildInputs = [ pkgsi686Linux.autoPatchelfHook ];
    buildInputs = libraries;

    unpackPhase = ''
      runHook preUnpack

      sh "$src" --noexec --nox11 --target "$(pwd)"

      runHook postUnpack
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r * $out/
      rm -f $out/env-vars

      # Fix chdir failure
      mkdir -p $out/bin/Tropics1.7.0

      runHook postInstall
    '';
  };
in
stdenv.mkDerivation rec {
  inherit (sources.unigine-tropics) pname version;
  dontUnpack = true;

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${distPackage}/bin/Tropics $out/bin/unigine-tropics \
      --chdir ${distPackage} \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}" \
      --add-flags "-system_script" \
      --add-flags "tropics/unigine.cpp" \
      --add-flags "-engine_config" \
      --add-flags "${distPackage}/data/unigine.cfg" \
      --add-flags "-data_path" \
      --add-flags "../../"

    runHook postInstall
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
