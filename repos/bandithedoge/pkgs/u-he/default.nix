{
  pkgs,
  sources,
  ...
}: let
  mkUhe = product: {
    clap ? true,
    meta ? {},
    extraLibs ? [],
    postBuild ? null,
  }:
    pkgs.stdenv.mkDerivation {
      inherit (sources.${product}) pname version src;

      nativeBuildInputs = with pkgs; [
        autoPatchelfHook
      ];

      buildInputs = with pkgs;
        [
          glib
          gtk3
          xorg.xcbutil
          xorg.xcbutilkeysyms
        ]
        ++ extraLibs;

      buildPhase =
        ''
          mkdir -p $out
          cp -r ${product} $out/libexec

          mkdir -p $out/lib/vst
          ln -s $out/libexec/${product}.64.so $out/lib/vst/${product}.64.so

          mkdir -p $out/lib/vst3/${product}.vst3/Contents/{x86_64-linux,Resources/Documentation}
          ln -s $out/libexec/${product}.64.so $out/lib/vst3/${product}.vst3/Contents/x86_64-linux/${product}.so
          ln -s $out/libexec/*.pdf $out/lib/vst3/${product}.vst3/Contents/Resources/Documentation/
        ''
        + pkgs.lib.optionalString clap ''
          mkdir -p $out/lib/clap
          ln -s $out/libexec/${product}.64.so $out/lib/clap/${product}.64.clap
        '';

      inherit postBuild;

      passthru = {
        inherit product;
      };

      meta =
        meta
        // {
          license = pkgs.lib.licenses.unfree;
          platforms = ["x86_64-linux"];
        };
    };
in {
  ace = mkUhe "ACE" {
    meta = {
      homepage = "https://u-he.com/products/ace/";
      description = "Gateway into modular";
    };
  };

  bazille = mkUhe "Bazille" {
    meta = {
      homepage = "https://u-he.com/products/bazille/";
      description = "Modular Synthesizer";
    };
  };

  colourcopy = mkUhe "ColourCopy" {
    meta = {
      homepage = "https://u-he.com/products/colourcopy/";
      description = "Bucket Brigade Delay";
    };
  };

  diva = mkUhe "Diva" {
    meta = {
      homepage = "https://u-he.com/products/diva/";
      description = "The spirit of analogue";
    };
  };

  filterscape = mkUhe "Filterscape" {
    meta = {
      homepage = "https://u-he.com/products/filterscape/";
      description = "The creative multi-talent";
    };
  };

  hive = mkUhe "Hive" {
    meta = {
      homepage = "https://u-he.com/products/hive/";
      description = "Sleek, streamlined, supercharged";
    };
  };

  mfm2 = mkUhe "MFM2" {
    meta = {
      homepage = "https://u-he.com/products/mfm2/";
      description = "Delay heaven";
    };
  };

  podolski = mkUhe "Podolski" {
    meta = {
      homepage = "https://u-he.com/products/podolski/";
      description = "Nice and easy";
    };
  };

  presswerk = mkUhe "Presswerk" {
    clap = false;
    meta = {
      homepage = "https://u-he.com/products/presswerk/";
      description = "Compression with musical soul";
    };
  };

  protoverb = mkUhe "Protoverb" {
    meta = {
      homepage = "https://u-he.com/products/protoverb/";
      description = "Experimental research reverb";
    };
  };

  repro = mkUhe "Repro-1" {
    clap = false;
    meta = {
      homepage = "https://u-he.com/products/repro/";
      description = "Two classics, recreated";
    };
  };

  satin = mkUhe "Satin" {
    meta = {
      homepage = "https://u-he.com/products/satin/";
      description = "Tape simulation";
    };
  };

  triplecheese = mkUhe "TripleCheese" {
    clap = false;
    meta = {
      homepage = "https://u-he.com/products/triplecheese/";
      description = "Luscious and cheesy";
    };
  };

  twangstrom = mkUhe "Twangstrom" {
    meta = {
      homepage = "https://u-he.com/products/twangstrom/";
      description = "Spring Reverberator";
    };
  };

  uhbik = mkUhe "Uhbik" {
    clap = false;
    meta = {
      homepage = "https://u-he.com/products/uhbik/";
      description = "Nine subtle to spectacular effects";
    };
  };

  zebra2 = mkUhe "Zebra2" {
    clap = false;
    meta = {
      homepage = "https://u-he.com/products/zebra-legacy/";
      description = "The workhorse synth";
    };
  };
}
