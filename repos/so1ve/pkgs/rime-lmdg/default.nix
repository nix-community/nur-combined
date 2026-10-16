{
  callPackage,
  lib,
  source ? callPackage ./source.nix { },
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "rime-lmdg";
  inherit (source) version src;

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 "$src" "$out/share/rime-data/wanxiang-lts-zh-hans.gram"

    runHook postInstall
  '';

  meta = {
    description = "Wanxiang simplified Chinese grammar model for Rime";
    homepage = "https://github.com/amzxyz/rime-wanxiang-data";
    license = lib.licenses.cc-by-40;
    sourceProvenance = [ lib.sourceTypes.binaryBytecode ];
    platforms = lib.platforms.all;
  };
}
