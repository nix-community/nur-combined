{
  sources,
  version,
  lib,
  callPackage,
  ffmpeg,
  ffms,
  ...
}:
let
  svt-av1-psy = callPackage ../svt-av1-shared { inherit sources version; };
in
svt-av1-psy.overrideAttrs (
  _final: prev: {
    cmakeFlags = prev.cmakeFlags ++ [
      (lib.cmakeBool "USE_FFMS2" true)
      # (lib.cmakeBool "USE_WEBM_IO" true)
    ];
    buildInputs = prev.buildInputs ++ [
      ffmpeg
      ffms
    ];
  }
)
