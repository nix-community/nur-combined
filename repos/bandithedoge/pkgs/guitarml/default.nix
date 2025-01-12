{
  pkgs,
  sources,
  utils,
  ...
}: let
  mkGuitarMl = {
    source,
    meta,
    version ? source.version,
  }:
    utils.juce.mkJucePackage {
      inherit (source) pname src;
      inherit version;

      meta = with pkgs.lib;
        {
          license = licenses.gpl3Only;
          platforms = platforms.linux;
        }
        // meta;
    };
in {
  proteus = mkGuitarMl {
    source = sources.proteus;
    meta = {
      homepage = "https://github.com/GuitarML/Proteus";
      description = "Guitar amp and pedal capture plugin using neural networks";
    };
  };

  prince = mkGuitarMl {
    source = sources.prince;
    meta = {
      homepage = "https://github.com/GuitarML/PrincePedal";
      description = "Prince of Tone style guitar plugin made with neural networks";
    };
  };

  ts-m1n3 = mkGuitarMl {
    source = sources.ts-m1n3;
    version = sources.ts-m1n3.date;
    meta = {
      homepage = "https://github.com/GuitarML/TS-M1N3";
      description = "TS-9 guitar pedal clone using neural networks";
    };
  };

  chameleon = mkGuitarMl {
    source = sources.chameleon;
    version = sources.chameleon.date;
    meta = {
      homepage = "https://github.com/GuitarML/Chameleon";
      description = "Vintage guitar amp using neural networks";
    };
  };

  smartamp = mkGuitarMl {
    source = sources.smartamp;
    version = sources.smartamp.date;
    meta = {
      homepage = "https://github.com/GuitarML/SmartGuitarAmp";
      description = "Guitar plugin made with JUCE that uses neural networks to emulate a tube amplifier";
    };
  };

  smartpedal = mkGuitarMl {
    source = sources.smartpedal;
    version = sources.smartpedal.date;
    meta = {
      homepage = "https://github.com/GuitarML/SmartGuitarPedal";
      description = "Guitar plugin made with JUCE that uses neural network models to emulate real world hardware";
    };
  };
}
