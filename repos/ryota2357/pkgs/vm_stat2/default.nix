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
    cp build/vm_stat2 $out/bin/

    runHook postInstall
  '';

  meta = {
    description = "An improved vm_stat command for macOS";
    homepage = "https://github.com/ryota2357/vm_stat2";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "vm_stat2";
  };
}
