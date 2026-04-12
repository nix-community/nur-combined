{
  lib,
  stdenv,
  source,
}:

stdenv.mkDerivation {
  inherit (source) pname src;
  version = "unstable-${source.date}";

  makeFlags = [ "CC=${stdenv.cc.targetPrefix}cc" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp build/ime $out/bin/

    runHook postInstall
  '';

  meta = {
    description = "Tiny macOS CLI to get, set, and list keyboard input sources";
    homepage = "https://github.com/ryota2357/ime";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "ime";
  };
}
