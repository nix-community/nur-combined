{
  lib,
  stdenvNoCC,
  fetchurl,
  undmg,
  makeWrapper,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "marta";
  version = "0.8.1";

  src = fetchurl {
    url = "https://updates.marta.sh/release/Marta-${finalAttrs.version}.dmg";
    hash = "sha256-DbNkvLCy6q0CN8b4+8oheM4EaaLAQvH3O5zWVYxEyh8=";
  };

  nativeBuildInputs = [
    undmg
    makeWrapper
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    mkdir -p $out/Applications
    mv *.app $out/Applications
    makeWrapper $out/{Applications/Marta.app/Contents/MacOS/Marta,bin/marta}
    runHook postInstall
  '';

  meta = {
    description = "File Manager for macOS";
    homepage = "https://marta.sh/";
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    license = lib.licenses.free;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = [ "x86_64-darwin" ];
    mainProgram = "marta";
    skip.ci = true;
  };
})
