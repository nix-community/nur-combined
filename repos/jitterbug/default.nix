{ pkgs ? import <nixpkgs> { } }: rec
{
  modules = import ./modules;
  overlays = import ./overlays;

  amcdx-video-patcher-cli = pkgs.callPackage ./pkgs/amcdx-video-patcher-cli { };
  ltfs = pkgs.callPackage ./pkgs/ltfs { };
  stfs = pkgs.callPackage ./pkgs/stfs { };
  vapoursynth-bwdif = pkgs.callPackage ./pkgs/vapoursynth-bwdif { };
  vapoursynth-neofft3d = pkgs.callPackage ./pkgs/vapoursynth-neofft3d { };
  vapoursynth-vsrawsource = pkgs.callPackage ./pkgs/vapoursynth-vsrawsource { };
  pyhht = pkgs.python3.pkgs.callPackage ./pkgs/pyhht { };
  qwt = pkgs.callPackage ./pkgs/qwt { };
  vhs-decode = pkgs.callPackage ./pkgs/vhs-decode { inherit qwt; };
  tbc-video-export = pkgs.python3.pkgs.callPackage ./pkgs/tbc-video-export { };
  domesdayduplicator = pkgs.callPackage ./pkgs/domesdayduplicator { };
  misrc-extract = pkgs.callPackage ./pkgs/misrc-extract { };
  vhs-decode-auto-audio-align = pkgs.callPackage ./pkgs/vhs-decode-auto-audio-align { };
  #tzpfms = pkgs.callPackage ./pkgs/tzpfms { };
}
