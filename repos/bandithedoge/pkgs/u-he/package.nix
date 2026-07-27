{
  sources,

  lib,
  stdenv,

  autoPatchelfHook,
  autoreconfHook,
  glib,
  gtk3,
  libxcb,
  libxcb-cursor,
  libxcb-keysyms,
  libxcb-util,
  unzip,
}:
let
  patchelf-raphi = stdenv.mkDerivation {
    inherit (sources.patchelf-raphi) pname version src;
    nativeBuildInputs = [ autoreconfHook ];
    meta.mainProgram = "patchelf";
  };

  mkUhe =
    product:
    {
      clap ? true,
      meta ? { },
      extraLibs ? [ ],
      nativeBuildInputs ? [ ],
      preBuild ? null,
      postBuild ? null,
    }:
    stdenv.mkDerivation {
      inherit (sources.${product}) pname version src;

      nativeBuildInputs = [
        autoPatchelfHook
      ]
      ++ nativeBuildInputs;

      buildInputs = [
        glib
        gtk3
        libxcb
        libxcb-keysyms
        libxcb-util
      ]
      ++ extraLibs;

      buildPhase = ''
        runHook preBuild

        mkdir -p $out/libexec
        cp -r ${product} $out/libexec/${product}
        for p in $out/libexec/${product}/Presets/*; do
          mkdir -p "$p/MIDI Programs"
        done

        # adapted from https://git.sr.ht/~raphi/elf-replace-symbol/tree/master/item/libfprint2-tod1-broadcom/default.nix
        substitute ${./wrapper.c} wrapper.c \
          --subst-var-by store_path $out/libexec/${product}
        cc -fPIC -shared -O3 wrapper.c -o $out/libexec/${product}/snprintf_wrapper_${product}.so

        ${lib.getExe patchelf-raphi} \
          --replace-symbol snprintf snprintf_wrapper \
          --add-needed snprintf_wrapper_${product}.so \
          $out/libexec/${product}/${product}.64.so

        mkdir -p $out/lib/vst
        ln -s $out/libexec/${product}/${product}.64.so $out/lib/vst/${product}.64.so

        mkdir -p $out/lib/vst3/${product}.vst3/Contents/{x86_64-linux,Resources/Documentation}
        ln -s $out/libexec/${product}/${product}.64.so $out/lib/vst3/${product}.vst3/Contents/x86_64-linux/${product}.so
        ln -s $out/libexec/${product}/*.pdf $out/lib/vst3/${product}.vst3/Contents/Resources/Documentation/
      ''
      + (lib.optionalString clap ''
        mkdir -p $out/lib/clap
        ln -s $out/libexec/${product}/${product}.64.so $out/lib/clap/${product}.64.clap
      '')
      + ''
        runHook postBuild
      '';

      inherit preBuild postBuild;

      passthru = {
        inherit product;
      };

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

  bazillecm = mkUhe "BazilleCM" {
    meta = {
      homepage = "https://u-he.com/products/bazillecm/";
      description = "Little modular monster";
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
    clap = false;
    meta = {
      homepage = "https://u-he.com/products/podolski/";
      description = "Nice and easy";
    };
  };

  presswerk = mkUhe "Presswerk" {
    meta = {
      homepage = "https://u-he.com/products/presswerk/";
      description = "Compression with musical soul";
    };
  };

  protoverb = mkUhe "Protoverb" {
    clap = false;
    meta = {
      homepage = "https://u-he.com/products/protoverb/";
      description = "Experimental research reverb";
    };
  };

  repro = mkUhe "Repro-1" {
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

  tyrelln6 = mkUhe "TyrellN6" {
    meta = {
      homepage = "https://u-he.com/products/tyrelln6/";
      description = "A classic racer";
    };
  };

  uhbik = mkUhe "Uhbik" {
    meta = {
      homepage = "https://u-he.com/products/uhbik/";
      description = "Nine subtle to spectacular effects";
    };
  };

  zebra-legacy = mkUhe "Zebra2" {
    nativeBuildInputs = [ unzip ];
    preBuild = ''
      tar -xf 01\ Zebra2/*.xz
      cp -r Zebra2*/Zebra2 .
    '';
    postBuild = ''
      tar -xf 02\ The\ Dark\ Zebra/*.tar.xz
      cp -r ZebraHZ*/ZebraHZ/* $out/libexec/Zebra2/

      mkdir -p $out/libexec/Zebra2/Presets/{ZRev,ZebraHZ}/MIDI\ Programs

      ${lib.getExe patchelf-raphi} \
        --replace-symbol snprintf snprintf_wrapper \
        --add-needed snprintf_wrapper_Zebra2.so \
        $out/libexec/Zebra2/ZebraHZ.64.so

      ln -s $out/libexec/Zebra2/ZebraHZ.64.so $out/lib/vst/ZebraHZ.so
      mkdir -p $out/lib/vst3/ZebraHZ.vst3/Contents/{x86_64-linux,Resources/Documentation}
      ln -s $out/libexec/Zebra2/ZebraHZ.64.so $out/lib/vst3/ZebraHZ.vst3/Contents/x86_64-linux/ZebraHZ.so
      ln -s $out/libexec/Zebra2/*.pdf $out/lib/vst3/ZebraHZ.vst3/Contents/Resources/Documentation/

      for soundset in 03\ Zebra\ Legacy\ Soundsets/*.uhe-soundset; do
        unzip -o "$soundset" -d $out/libexec/Zebra2
      done
    '';

    meta = {
      homepage = "https://u-he.com/products/zebra-legacy/";
      description = "The workhorse synth";
    };
  };

  zebracm = mkUhe "ZebraCM" {
    meta = {
      homepage = "https://u-he.com/products/zebracm/";
      description = "Baby zebra";
    };
  };

  zebra3 = mkUhe "Zebra3" {
    postBuild = ''
      mkdir -p $out/libexec/Zebra3/{Modules/{Envelope,LFO,MSEG},Tunefiles}/User
    '';
    extraLibs = [ libxcb-cursor ];

    meta = {
      homepage = "https://u-he.com/products/synths/zebra3/";
      description = "Deep Synthesis";
    };
  };
}
