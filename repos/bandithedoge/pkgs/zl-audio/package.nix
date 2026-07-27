{
  sources,

  lib,
  stdenv,

  juceCmakeHook,
}:
let
  mkZl =
    {
      pname,
      source,
      version ? source.version,
      meta,
      extraCmakeFlags ? [ ],
      cflags ? [ ],
    }:
    stdenv.mkDerivation {
      inherit pname version;
      inherit (source) src;

      nativeBuildInputs = [ juceCmakeHook ];

      cmakeFlags = [
        "-DZL_JUCE_COPY_PLUGIN=FALSE"
      ]
      ++ extraCmakeFlags;

      NIX_CFLAGS_COMPILE = cflags;

      meta = {
        license = lib.licenses.gpl3Plus;
        platforms = lib.platforms.linux;
        maintainers = [ lib.maintainers.bandithedoge ];
      }
      // meta;
    };
in
{
  warm = mkZl {
    pname = "ZLWarm";
    source = sources.warm;
    meta = {
      description = "distortion/saturation plugin";
      homepage = "https://github.com/ZL-Audio/ZLWarm";
    };
  };

  lmakeup = mkZl {
    pname = "ZLLMakeup";
    source = sources.lmakeup;
    version = lib.removePrefix "v" sources.lmakeup.version;
    meta = {
      description = "loudness make-up plugin";
      homepage = "https://github.com/ZL-Audio/ZLLMakeup";
    };
  };

  lmatch = mkZl {
    pname = "ZLLMatch";
    source = sources.lmatch;
    version = lib.removePrefix "v" sources.lmatch.version;
    meta = {
      description = "loudness matching plugin";
      homepage = "https://github.com/ZL-Audio/ZLLMatch";
    };
  };

  inflator = mkZl {
    pname = "ZLInflator";
    source = sources.inflator;
    meta = {
      description = "distortion/saturation plugin";
      homepage = "https://github.com/ZL-Audio/ZLInflator";
    };
  };
}
