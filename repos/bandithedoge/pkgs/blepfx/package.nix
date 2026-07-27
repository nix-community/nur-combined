{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  libGL,
  libx11,
  libxcb,
  unzip,
}:
let
  mkBlep =
    {
      source,
      description,
      homepage,
    }:
    stdenv.mkDerivation {
      inherit (source) pname src;
      version = lib.removePrefix "version-" source.version;

      sourceRoot = ".";

      nativeBuildInputs = [
        unzip
        autoPatchelfHook
      ];

      buildInputs = [
        libGL
        libx11
        libxcb
      ];

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/lib/{clap,vst3}
        cp ${source.pname}.clap $out/lib/clap/${source.pname}.clap
        cp -r ${source.pname}.vst3 $out/lib/vst3/${source.pname}.vst3

        runHook postBuild
      '';

      meta = {
        inherit description homepage;
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      };
    };
in
{
  crunchrr = mkBlep {
    source = sources.crunchrr;
    description = "crunchrr is a really simple to use effect that adds digital artifacts to your sounds. It works by modulating a small fractional delay line at an audio rate at high frequency, resulting in a bit crush/sample divide/erosion kind of effect";
    homepage = "https://fx.amee.ee/plugin/crunchrr/";
  };

  destruqtor = mkBlep {
    source = sources.destruqtor;
    description = "destruqtor is a companding distortion/saturation/exciter plugin. Unlike traditional distortion, destruqtor applies expanding compression before the waveshaper and an opposite compression after the effect, which preserves and emphasises transients and adds more warmth to your sounds without sacrificing dynamic range";
    homepage = "https://fx.amee.ee/plugin/destruqtor/";
  };

  filtrr = mkBlep {
    source = sources.filtrr;
    description = "filtrr is not just a filter! filtrr is a nonlinear ladder filter that is capable of producing a large variety of sounds";
    homepage = "https://fx.amee.ee/plugin/filtrr/";
  };

  prisma = mkBlep {
    source = sources.prisma;
    description = "prisma is an FFT based 3-in-1 plugin. It's a pitch shifter that works even on polyphonic audio sources, a formant shifter, and a pitch quantizer (useful for achieving that iconic color bass sound)";
    homepage = "https://fx.amee.ee/plugin/prisma/";
  };
}
