{
  stdenv,
  sources,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  inherit (sources.vbmeta-disable-verification) pname version src;
  buildPhase = ''
    runHook preBuild

    cc -o vbmeta-disable-verification jni/main.c

    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp vbmeta-disable-verification $out/bin/vbmeta-disable-verification

    runHook postInstall
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Patch Android vbmeta image and disable verification flags inside.";
    homepage = "https://github.com/libxzr/vbmeta-disable-verification";
    license = licenses.mit;
  };
}
