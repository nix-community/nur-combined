{ lib, stdenvNoCC, fetchurl }:

# Official honk full build with native API and embedded doona.
stdenvNoCC.mkDerivation {
  pname = "honk-core";
  version = "0.1.0-beta.6";
  src = fetchurl {
    url = "https://github.com/daeuniverse/honk/releases/download/v0.1.0-beta.6/honk-core-v0.1.0-beta.6-x86_64-unknown-linux-musl-full.tar.gz";
    hash = "sha256-J4O48IVvwa7NHNHZEdmpBMWTzVB89h5fok+9cHUxckQ=";
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
    description = "honk transparent proxy with native API and embedded doona";
    homepage = "https://github.com/daeuniverse/honk";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "honk-core";
  };
}
