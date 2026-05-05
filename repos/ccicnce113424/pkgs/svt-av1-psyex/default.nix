{
  sources,
  version,
  lib,
  callPackage,
  stdenv,
  cpuinfo,
}:
let
  svt-av1-psy = callPackage ../svt-av1-shared { inherit sources version; };
in
svt-av1-psy.overrideAttrs (
  _final: prev: {
    buildInputs =
      prev.buildInputs
      ++ lib.optionals stdenv.hostPlatform.isx86_64 [
        cpuinfo
      ];
  }
)
