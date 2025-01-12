{
  pkgs,
  sources,
  utils,
  ...
}: let
  mkApisonic = {
    source,
    meta,
    sourceRoot ? "linux",
  }:
    pkgs.stdenv.mkDerivation {
      inherit (source) pname version src;
      inherit sourceRoot;

      nativeBuildInputs = with pkgs; [
        autoPatchelfHook
        unzip
      ];

      buildInputs = utils.juce.commonBuildInputs;

      buildPhase = ''
        mkdir -p $out/lib/{vst,vst3}
        cp -r .vst3/${source.pname}.vst3 $out/lib/vst3
        cp .vst/${source.pname}.so $out/lib/vst
      '';

      meta = with pkgs.lib;
        {
          license = licenses.unfree;
          platforms = ["x86_64-linux"];
          sourceProvenance = [sourceTypes.binaryNativeCode];
        }
        // meta;
    };
in {
  speedrum = mkApisonic {
    source = sources.Speedrum2;
    meta = {
      homepage = "https://www.apisonic-audio.com/speedrum2.html";
      description = "Drum/percussion sampler and sequencer plugin";
    };
  };

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
