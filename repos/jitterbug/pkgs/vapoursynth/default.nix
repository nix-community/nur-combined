{
  pkgs,
  ...
}:
let
  inherit (pkgs.callPackage ../lib { inherit pkgs; }) callPackage;
in
{
  vapoursynth-analog = callPackage ./vapoursynth-analog { };
  vapoursynth-bwdif = callPackage ./vapoursynth-bwdif { };
  vapoursynth-neofft3d = callPackage ./vapoursynth-neofft3d { };
  vapoursynth-vsrawsource = callPackage ./vapoursynth-vsrawsource { };
}
