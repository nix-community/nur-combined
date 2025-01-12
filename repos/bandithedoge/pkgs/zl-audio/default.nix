{
  pkgs,
  sources,
  utils,
  ...
}: let
  mkZl = {
    pname,
    prettyName,
    source,
    version ? source.version,
    meta,
    cflags ? [],
  }:
    utils.juce.mkJucePackage {
      inherit pname version;
      inherit (source) src;

      cmakeFlags = ["-DBUILD_SHARED_LIBS=OFF"];

      NIX_CFLAGS_COMPILE = cflags;

      meta = with pkgs.lib;
        {
          license = licenses.gpl3Only;
          platforms = platforms.linux;
        }
        // meta;
    };
in {
  equalizer = mkZl {
    pname = "ZLEqualizer";
    prettyName = "ZL Equalizer";
    source = sources.equalizer;
    meta = {
      description = "equalizer plugin";
      homepage = "https://zl-audio.github.io/plugins/zlequalizer/";
      license = pkgs.lib.licenses.agpl3Only;
    };
  };

  compressor = mkZl {
    pname = "ZLCompressor";
    prettyName = "ZL Compressor";
    source = sources.compressor;
    version = sources.compressor.date;
    meta = {
      description = "compressor plugin";
      homepage = "https://github.com/ZL-Audio/ZLCompressor";
    };
  };

  splitter = mkZl {
    pname = "ZLSplitter";
    prettyName = "ZL Splitter";
    source = sources.splitter;
    meta = {
      description = "splitter plugin";
      homepage = "https://zl-audio.github.io/plugins/zlsplitter/";
    };
    cflags = ["-Wno-changes-meaning"];
  };

  warm = mkZl {
    pname = "ZLWarm";
    prettyName = "ZL Warm";
    source = sources.warm;
    meta = {
      description = "distortion/saturation plugin";
      homepage = "https://github.com/ZL-Audio/ZLWarm";
    };
  };

  lmakeup = mkZl {
    pname = "ZLLMakeup";
    prettyName = "ZL Loudness Makeup";
    source = sources.lmakeup;
    meta = {
      description = "loudness make-up plugin";
      homepage = "https://github.com/ZL-Audio/ZLLMakeup";
    };
  };

  lmatch = mkZl {
    pname = "ZLLMatch";
    prettyName = "ZL Loudness Match";
    source = sources.lmatch;
    meta = {
      description = "loudness matching plugin";
      homepage = "https://github.com/ZL-Audio/ZLLMatch";
    };
  };

  inflator = mkZl {
    pname = "ZLInflator";
    prettyName = "ZL Inflator";
    source = sources.inflator;
    meta = {
      description = "distortion/saturation plugin";
      homepage = "https://github.com/ZL-Audio/ZLInflator";
    };
  };
}
