{ lib, stdenvNoCC, fetchurl }:

# Matching honk/native-api + embedded doona build from the same release.
stdenvNoCC.mkDerivation {
  pname = "honk-core";
  version = "debug.2026.10.12.native-api.1";
  src = fetchurl {
    url = "https://github.com/Zakkaus/doona/releases/download/v0.1.0-beta.20/honk-core-debug-x86_64-unknown-linux-musl.tar.gz";
    sha256 = "304f0d8f6eccb0915f0653f0dfe9c4a98cec297f628d0edd21daf0738b58b60f";
  };
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;
  dontPatchELF = true;
  installPhase = ''
    runHook preInstall
    install -Dm755 honk-core $out/bin/honk-core
    runHook postInstall
  '';
  meta = {
    description = "honk transparent proxy with native API and embedded doona beta.20";
    homepage = "https://github.com/Glassyiris/honk";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "honk-core";
  };
}
