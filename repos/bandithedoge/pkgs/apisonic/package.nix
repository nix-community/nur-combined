{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  juceCmakeHook,
  unzip,
}:
let
  mkApisonic =
    {
      source,
      meta,
      sourceRoot ? "linux",
    }:
    stdenv.mkDerivation {
      inherit (source) pname src;
      version = lib.removePrefix "v" source.version;
      inherit sourceRoot;

      nativeBuildInputs = [
        autoPatchelfHook
        unzip
      ];

      buildInputs = juceCmakeHook.commonBuildInputs;

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/lib/{vst,vst3}
        cp -r .vst3/${source.pname}.vst3 $out/lib/vst3
        cp .vst/${source.pname}.so $out/lib/vst

        runHook postBuild
      '';

      meta = {
        license = lib.licenses.unfree;
        platforms = [ "x86_64-linux" ];
        sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
in
{
  speedrum =
    (mkApisonic {
      source = sources.Speedrum2;
      meta = {
        homepage = "https://www.apisonic-audio.com/speedrum2.html";
        description = "Drum/percussion sampler and sequencer plugin";
      };
    }).overrideAttrs
      (_: {
        buildPhase = ''
          runHook preBuild

          mkdir -p $out/{bin,lib/vst,lib/vst3}
          cp Standalone/Speedrum2 $out/bin
          chmod +x $out/bin/Speedrum2
          cp -r VST3/Speedrum2.vst3 $out/lib/vst3
          cp VST/libSpeedrum2.so $out/lib/vst

          runHook postBuild
        '';
      });

  speedrum1 = mkApisonic {
    source = sources.Speedrum;
    meta = {
      homepage = "https://www.apisonic-audio.com/speedrum1.html";
      description = "Drum/percussion sampler and sequencer plugin";
    };
  };

  speedrum-lite = mkApisonic {
    source = sources.SpeedrumLite;
    meta = {
      homepage = "https://www.apisonic-audio.com/freeware.html";
      description = "A 'simple' drum - percussion MPC style sampler";
    };
  };

  transperc = mkApisonic {
    source = sources.Transperc;
    sourceRoot = "transperc/linux";
    meta = {
      homepage = "https://www.apisonic-audio.com/freeware.html";
      description = "Transient processor (shaper) created mainly for percussive material, but can be used on any type of sound";
    };
  };
}
