{ lib, stdenvNoCC, fetchurl }:

# Matching honk/native-api + embedded doona build from the same release.
stdenvNoCC.mkDerivation {
  pname = "honk-core";
  version = "0.1.0-beta.20";
  src = fetchurl {
    url = "https://github.com/Zakkaus/doona/releases/download/v0.1.0-beta.20/honk-core-debug-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-ME8Nj27MsJFfBlPw3+nEqYzsKX9ijQ7dIdrwc4tYtg8=";
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
