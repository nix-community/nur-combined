{
  pkgs,
  sources,
  ...
}: let
  mkTal = {
    product,
    source,
    description,
    homepage,
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
          alsa-lib
          fontconfig
          freetype
          libGL
          libgcc.lib
        ]
        ++ extraLibs;

      buildPhase = ''
        mkdir -p $out/lib/vst $out/lib/vst3 $out/lib/clap
        cp lib${product}.so $out/lib/vst
        cp -r ${product}.vst3 $out/lib/vst3
        cp ${product}.clap $out/lib/clap
      '';

      meta = with pkgs.lib; {
        inherit description homepage;
        license = licenses.unfree;
        platforms = ["x86_64-linux"];
        sourceProvenance = [sourceTypes.binaryNativeCode];
      };
    };
in {
  bassline-101 = mkTal {
    product = "TAL-BassLine-101";
    source = sources.bassline-101;
    description = "TAL-BassLine-101 is an accurate emulation of the popular SH 101";
    homepage = "https://tal-software.com/products/tal-bassline-101";
  };

  chorus-lx = mkTal {
    product = "TAL-Chorus-LX";
    source = sources.chorus-lx;
    description = "TAL-Chorus-LX is a 1:1 copy of the chorus implemented in TAL-U-NO-LX";
    homepage = "https://tal-software.com/products/tal-chorus-lx";
  };

  dac = mkTal {
    product = "TAL-DAC";
    source = sources.dac;
    description = "TAL-DAC brings back the character and sound of the 80's samplers and Lo-Fi devices in one effect plug-in. You can use it for subtle sound changes but also extreme effects.";
    homepage = "https://tal-software.com/products/tal-dac";
  };

  drum = mkTal {
    product = "TAL-Drum";
    source = sources.drum;
    description = "TAL-Drum is a powerful audio plug-in that combines the nostalgic charm of vintage drum machines with modern usability. This intuitive tool lets you effortlessly create captivating beats with its meticulously sampled collection of iconic drum machine sounds.";
    homepage = "https://tal-software.com/products/tal-drum";
  };

  dub-x = mkTal {
    product = "TAL-Dub-X";
    source = sources.dub-x;
    description = "TAL-Dub-X is a remake of our popular original freeware TAL-Dub plug-in with a lot of additional features";
    homepage = "https://tal-software.com/products/tal-dub-x";
  };

  filter-2 = mkTal {
    product = "TAL-Filter-2";
    source = sources.filter-2;
    description = "TAL-Filter-2 is a host synced filter module with different filter types, panorama and volume modulation possibilities";
    homepage = "https://tal-software.com/products/tal-filter";
  };

  g-verb = mkTal {
    product = "TAL-G-Verb";
    source = sources.g-verb;
    description = "TAL-G-Verb is a musical effect capable to build high quality artificial reverb sounds";
    homepage = "https://tal-software.com/products/tal-g-verb";
  };

  j-8 = mkTal {
    product = "TAL-J-8";
    source = sources.j-8;
    description = "TAL-J-8 is a synthesizer plug-in that meticulously emulates the legendary Jupiter 8 and is calibrated after our hardware device, delivering the most authentic and faithful reproduction of its iconic sound";
    homepage = "https://tal-software.com/products/tal-j-8";
    extraLibs = with pkgs; [curl];
  };

  mod = mkTal {
    product = "TAL-Mod";
    source = sources.mod;
    description = "TAL-Mod is a virtual analog synthesizer with an exceptional sound and almost unlimited modulation possiblities. Its special oscillator model is able to create a wide range of sounds, from classic mono to rich stereo leads, effects and pads.";
    homepage = "https://tal-software.com/products/tal-mod";
  };

  noisemaker = mkTal {
    product = "TAL-NoiseMaker";
    source = sources.noisemaker;
    description = "TAL-NoiseMaker is a virtual analog synthesizer with a great sound and low CPU usage. 128 factory presets included.";
    homepage = "https://tal-software.com/products/tal-noisemaker";
  };

  pha = mkTal {
    product = "TAL-Pha";
    source = sources.pha;
    description = "TAL-Pha is an instrument plug-in that emulates the sound of the analog 80's synthesizer Alpha Juno II (MKS-50 is the rack version)";
    homepage = "https://tal-software.com/products/tal-pha";
  };

  reverb-4 = mkTal {
    product = "TAL-Reverb-4";
    source = sources.reverb-4;
    description = "TAL-Reverb-4 is a high quality plate reverb with a vintage 80's character";
    homepage = "https://tal-software.com/products/tal-reverb-4";
  };

  sampler = mkTal {
    product = "TAL-Sampler";
    source = sources.sampler;
    description = "TAL-Sampler is not just a sample player. It's a full featured analog modeled synthesizer with a sampler engine as sound source, including a powerful modulation matrix and high quality self-oscillating filters.";
    homepage = "https://tal-software.com/products/tal-sampler";
  };

  u-no-lx = mkTal {
    product = "TAL-U-NO-LX-V2";
    source = sources.u-no-lx;
    description = "TAL-U-NO-LX is a synthesizer plug-in that faithfully recreates the iconic sound of the analog Juno 60 synth. Each oscillator, filter, and envelope has been painstakingly modeled to capture the essence of the original hardware, delivering an unparalleled level of authenticity.";
    homepage = "https://tal-software.com/products/tal-u-no-lx";
  };

  vocoder = mkTal {
    product = "TAL-Vocoder-2";
    source = sources.vocoder;
    description = "TAL-Vocoder is a vintage-style vocoder with 11 bands that produces the sound of vocoders from the early 80’s. We mixed analog-modeled components and usability with digital algorithms to create an outstanding vocoder sound.";
    homepage = "https://tal-software.com/products/tal-vocoder";
  };
}
