{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  libx11,
  unzip,
}:
let
  mkKlknn =
    source:
    stdenv.mkDerivation {
      inherit (source) pname src;
      version = lib.removePrefix "v" source.version;

      nativeBuildInputs = [
        autoPatchelfHook
        unzip
      ];

      buildInputs = [
        libx11
        stdenv.cc.cc.lib
      ];

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/lib
        cp -r Linux-64b-LV2 $out/lib/lv2
        cp -r Linux-64b-VST3 $out/lib/vst3
        cp -r Linux-64b-VST2 $out/lib/vst

        runHook postBuild
      '';

      meta = {
        homepage = "https://github.com/klknn/kdr";
        license = lib.licenses.boost;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      };
    };
in
{
  envtool-bin = mkKlknn sources.envtool-bin;
  epiano2-bin = mkKlknn sources.epiano2-bin;
  freeverb-bin = mkKlknn sources.freeverb-bin;
  synth2-bin = mkKlknn sources.synth2-bin;
}
