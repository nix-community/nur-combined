{
  lib,
  stdenv,
  fetchzip,

  autoPatchelfHook,
  curl-gnutls3,
  libGL,
  libx11,
  libxext,
}:
let
  mkHarrison =
    {
      pname,
      version,
      src,
    }:
    stdenv.mkDerivation {
      inherit pname version src;

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
  _32c = mkHarrison rec {
    pname = "harrison-32c";
    version = "3-5-22";
    src = fetchzip {
      url = "https://rsrc.harrisonconsoles.com/ava/release/32C/${version}/Harrison_32C-linux-amd64.tar.gz";
      sha256 = "sha256-2Bthoz/7RdVAGIXbAd0y/mIwWfcu2NNni95BWqNnCoI=";
    };
  };
  ava = mkHarrison rec {
    pname = "harrison-ava";
    version = "10-27-22";
    src = fetchzip {
      url = "https://rsrc.harrisonconsoles.com/ava/release/AVA/${version}/Harrison_AVA-linux-amd64.tar.gz";
      sha256 = "sha256-jkluEUfJjFfi3mOgx5FIDKr7E972UiKJNL/gEp5E5HU=";
    };
  };
}
