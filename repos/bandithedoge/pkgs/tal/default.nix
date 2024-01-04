{
  pkgs,
  sources,
  ...
}: let
  mkTal = {
    product,
    source,
    extraLibs ? [],
  }:
    pkgs.stdenv.mkDerivation {
      pname = product;
      inherit (source) version src;

      nativeBuildInputs = with pkgs; [
        autoPatchelfHook
        unzip
      ];

      buildInputs = with pkgs;
        [
          freetype
          alsa-lib
          libgcc.lib
        ]
        ++ extraLibs;

      buildPhase = ''
        mkdir -p $out/lib/vst $out/lib/vst3 $out/lib/clap
        cp lib${product}.so $out/lib/vst
        cp -r ${product}.vst3 $out/lib/vst3
        cp ${product}.clap $out/lib/clap
      '';
    };
in {
  bassline-101 = mkTal {
    product = "TAL-BassLine-101";
    source = sources.bassline-101;
  };

  chorus-lx = mkTal {
    product = "TAL-Chorus-LX";
    source = sources.chorus-lx;
  };

  dac = mkTal {
    product = "TAL-DAC";
    source = sources.dac;
  };

  drum = mkTal {
    product = "TAL-Drum";
    source = sources.drum;
    extraLibs = with pkgs; [libGL];
  };

  dub-x = mkTal {
    product = "TAL-Dub-X";
    source = sources.dub-x;
  };

  filter-2 = mkTal {
    product = "TAL-Filter-2";
    source = sources.filter-2;
  };

  j-8 = mkTal {
    product = "TAL-J-8";
    source = sources.j-8;
  };

  mod = mkTal {
    product = "TAL-Mod";
    source = sources.mod;
  };

  noisemaker = mkTal {
    product = "TAL-NoiseMaker";
    source = sources.noisemaker;
  };

  reverb-4 = mkTal {
    product = "TAL-Reverb-4";
    source = sources.reverb-4;
  };

  sampler = mkTal {
    product = "TAL-Sampler";
    source = sources.sampler;
  };

  u-no-lx = mkTal {
    product = "TAL-U-NO-LX-V2";
    source = sources.u-no-lx;
  };

  vocoder = mkTal {
    product = "TAL-Vocoder-2";
    source = sources.vocoder;
  };
}
