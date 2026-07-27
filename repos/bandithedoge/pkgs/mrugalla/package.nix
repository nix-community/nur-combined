{
  sources,

  lib,
  stdenv,

  projucer,
}:
let
  mkMrugalla =
    {
      source,
      jucerFile ? "Project.jucer",
      meta ? { },
    }:
    stdenv.mkDerivation {
      inherit (source) pname src;
      version = source.date;

      nativeBuildInputs = [
        projucer
      ];

      inherit jucerFile;

      meta = {
        license = lib.licenses.gpl3Plus;
        platforms = lib.platforms.linux;
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
in
{
  absorb = mkMrugalla {
    source = sources.absorb;
    meta = {
      description = "Sidechain plugin that mixes up the texture of the colliding input signals";
      homepage = "github.com/Mrugalla/Absorb";
    };
  };

  adsr = mkMrugalla {
    source = sources.adsr;
    meta = {
      description = "Plugin that transforms MIDI input into an ADSR modulator audio output";
      homepage = "https://github.com/Mrugalla/ADSR";
      broken = true;
    };
  };

  allhaas = mkMrugalla {
    source = sources.allhaas;
    jucerFile = "ALLHaas.jucer";
    meta = {
      description = "Stereo widening tool that uses a lot of allpass filters";
      homepage = "https://github.com/Mrugalla/ALLHaas";
    };
  };

  hammer-and-meiszel = mkMrugalla {
    source = sources.hammer-and-meiszel;
    jucerFile = "Projekt.jucer";
    meta = {
      description = "Keytracked polyphonic modal filter effect";
      homepage = "https://github.com/Mrugalla/Hammer-and-Meiszel";
    };
  };

  jif = mkMrugalla {
    source = sources.jif;
    jucerFile = "JIF.jucer";
    meta = {
      description = "VST3 Plugin, that loops a GIF to the tempo of your beat";
      homepage = "https://github.com/Mrugalla/JIF";
      broken = true;
    };
  };

  manta = mkMrugalla {
    source = sources.manta;
    meta = {
      description = "Resonator with extra steps";
      homepage = "https://github.com/Mrugalla/Manta";
    };
  };

  nel-19 = mkMrugalla {
    source = sources.nel-19;
    jucerFile = "NEL-19.jucer";
    meta = {
      description = "Open-source vibrato plugin with an extensive modulation system";
      homepage = "https://github.com/Mrugalla/NEL-19";
    };
  };

  nelorbit = mkMrugalla {
    source = sources.nelorbit;
    jucerFile = "NELOrbit.jucer";
    meta = {
      description = "VST3 plugin where gravitating planets cause chorus modulation";
      homepage = "https://github.com/Mrugalla/NELOrbit";
      broken = true;
    };
  };

  overdrive-reneo = mkMrugalla {
    source = sources.overdrive-reneo;
    meta = {
      description = "mda overdrive tribute project";
      homepage = "https://github.com/Mrugalla/Overdrive-ReNEO";
    };
  };

  perlinnoisemod = mkMrugalla {
    source = sources.perlinnoisemod;
    meta = {
      description = "Plugin that synthesizes perlin noise";
      homepage = "https://github.com/Mrugalla/PerlinNoiseMod";
      broken = true;
    };
  };

  pitchglitcher = mkMrugalla {
    source = sources.pitchglitcher;
    meta = {
      description = "pitchshifter with a feedback parameter";
      homepage = "https://github.com/Mrugalla/PitchGlitcher";
      broken = true;
    };
  };

  slew-over = mkMrugalla {
    source = sources.slew-over;
    jucerFile = "Slew Over.jucer";
    meta = {
      description = "Simple slew limiter with oversampling";
      homepage = "https://github.com/Mrugalla/Slew-Over";
    };
  };

  susquash = mkMrugalla {
    source = sources.susquash;
    jucerFile = "susquash.jucer";
    meta = {
      description = "plugin that crushes shit massively";
      homepage = "https://github.com/Mrugalla/susquash";
    };
  };

  xen = mkMrugalla {
    source = sources.xen;
    jucerFile = "Xen.jucer";
    meta = {
      description = "VSTi that transforms input MIDI to polyphonic xenharmonic MPE MIDI";
      homepage = "https://github.com/Mrugalla/Xen";
    };
  };
}
