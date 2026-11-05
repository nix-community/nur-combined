{
  callPackage,
  lib,
  source ? callPackage ./source.nix { },
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "rime-frost";
  inherit (source) version src;

  nativeBuildInputs = [ unzip ];
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/share/rime-data"
    unzip -q "$src" -d "$out/share/rime-data"

    runHook postInstall
  '';

  meta = {
    description = "White Frost Pinyin schemas, dictionaries, and language model for Rime";
    homepage = "https://github.com/gaboolic/rime-frost";
    changelog = "https://github.com/gaboolic/rime-frost/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.all;
  };
})
