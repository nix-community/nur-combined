{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  curl-gnutls3,
  libGL,
  libx11,
  libxext,
}:
let
  mkHarrison =
    source:
    stdenv.mkDerivation {
      inherit (source) pname version src;

      nativeBuildInputs = [
        autoPatchelfHook
      ];

      buildInputs = [
        curl-gnutls3
        libGL
        libx11
        libxext
      ];

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/lib
        cp -r vst $out/lib

        runHook postBuild
      '';

      meta = {
        homepage = "https://support.harrisonaudio.com/hc/en-gb/articles/19516617411613-Harrison-AVA-downloads-OLD-VERSIONS";
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      };
    };
in
{
  _32c = mkHarrison sources.harrison-32c;
  ava = mkHarrison sources.harrison-ava;
}
