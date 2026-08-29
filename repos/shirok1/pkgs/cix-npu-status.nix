{
  stdenv,
  cix-noe-umd,
}:

stdenv.mkDerivation {
  pname = "cix-npu-status";
  version = "1.0.0";
  dontUnpack = true;

  buildPhase = ''
    runHook preBuild
    $CC ${./cix-npu-status.c} \
      -I${cix-noe-umd}/include \
      -L${cix-noe-umd}/lib \
      -lnoe \
      -o cix-npu-status
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 cix-npu-status $out/bin/cix-npu-status
    runHook postInstall
  '';
}
