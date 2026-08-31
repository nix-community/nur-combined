{
  fetchurl,
  lib,
  stdenv,
  pkgsi686Linux,
  copyDesktopItems,
  makeDesktopItem,
  makeWrapper,
}:
let
  version = "2.3";

  libraries = with pkgsi686Linux; [
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

  distPackage = pkgsi686Linux.stdenv.mkDerivation {
    pname = "unigine-sanctuary";
    inherit version;
    src = fetchurl {
      url = "https://assets.unigine.com/d/Unigine_Sanctuary-${version}.run";
      hash = "sha256-KKi70ctkEm+tx0kjBMWVKMLDrJ1TsPH+CKLDMXA6OdU=";
    };
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
      mkdir -p $out/bin/Sanctuary0

      runHook postInstall
    '';
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "unigine-sanctuary";
  inherit version;
  dontUnpack = true;

  nativeBuildInputs = [
    copyDesktopItems
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${lib.getExe' distPackage "Sanctuary"} $out/bin/unigine-sanctuary \
      --chdir ${distPackage} \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath libraries}" \
      --add-flags "-system_script" \
      --add-flags "sanctuary/unigine.cpp" \
      --add-flags "-engine_config" \
      --add-flags "${distPackage}/data/unigine.cfg" \
      --add-flags "-data_path" \
      --add-flags "../../"

    runHook postInstall
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "unigine-sanctuary";
      exec = "unigine-sanctuary";
      desktopName = "Unigine Sanctuary";
      genericName = finalAttrs.meta.description;
      categories = [
        "Game"
        "Utility"
      ];
      terminal = false;
    })
  ];

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Extreme performance and stability test for PC hardware: video card, power supply, cooling system";
    homepage = "https://benchmark.unigine.com/sanctuary";
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "unigine-sanctuary";
  };
})
