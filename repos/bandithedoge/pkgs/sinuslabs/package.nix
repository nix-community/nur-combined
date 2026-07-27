{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
  unzip,
}:
let
  mkSinuslabs =
    {
      source,
      meta,
      sourceRoot ? ".",
    }:
    stdenv.mkDerivation {
      inherit (source) pname version src;
      inherit sourceRoot;

      nativeBuildInputs = [
        autoPatchelfHook
        unzip
      ];

      buildInputs = juceCmakeHook.commonBuildInputs;

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/lib/vst3
        cp -r *.vst3 $out/lib/vst3

        runHook postBuild
      '';

      meta = {
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
in
{
  bandbreite = mkSinuslabs {
    source = sources.bandbreite;
    sourceRoot = "Resources";
    meta = {
      description = "Add warm, analog character to your drums, basses, and 808s";
      homepage = "https://sinuslabs.io/products/bandbreite";
    };
  };

  ko = mkSinuslabs {
    source = sources.ko;
    sourceRoot = "KO-Installer";
    meta = {
      description = "KO is heavy hitting saturation and processing tool. Knockout power";
      homepage = "https://sinuslabs.io/products/ko";
    };
  };

  reach = mkSinuslabs {
    source = sources.reach;
    meta = {
      description = "Extraterrestrial Reverb with a unique Sound";
      homepage = "https://sinuslabs.io/products/reach";
      license = lib.licenses.gpl3Plus;
    };
  };
}
