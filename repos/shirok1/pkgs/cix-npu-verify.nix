{
  stdenv,
  lib,
  fetchurl,
  stb,
  cix-noe-umd,
}:

let
  imagenetLabels = fetchurl {
    url = "https://raw.githubusercontent.com/pytorch/hub/master/imagenet_classes.txt";
    hash = "sha256-HzhuDRy24oucLaxlHD3qaAHpitG0GhTOa7Ggk9cgafU=";
  };
in
stdenv.mkDerivation {
  pname = "cix-npu-verify";
  version = "1.0.0";
  dontUnpack = true;

  buildPhase = ''
    runHook preBuild
    $CC -std=c11 -Wall -Wextra -Werror ${./cix-npu-verify.c} \
      -I${cix-noe-umd}/include \
      -L${cix-noe-umd}/lib \
      -lnoe -lm \
      -o cix-npu-verify
    $CC -std=c11 -O2 -Wall -Wextra -Werror ${./cix-npu-verify-classify.c} \
      -I${cix-noe-umd}/include -I${stb}/include/stb \
      -DIMAGENET_LABELS='"${imagenetLabels}"' \
      -L${cix-noe-umd}/lib \
      -lnoe -lm \
      -o cix-npu-verify-classify
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 cix-npu-verify $out/bin/cix-npu-verify
    install -Dm755 cix-npu-classify $out/bin/cix-npu-classify
    runHook postInstall
  '';

  meta = {
    description = "Validate repeated CIX NPU inference against golden outputs";
    license = [
      lib.licenses.mit
      lib.licenses.unfreeRedistributable
    ];
    platforms = [ "aarch64-linux" ];
    mainProgram = "cix-npu-verify";
  };
}
