{ pkgs ? import <nixpkgs> { } }: rec
{
  modules = import ./modules;
  overlays = import ./overlays;

  ab-av1 = pkgs.callPackage ./pkgs/ab-av1 { };
  amcdx-video-patcher-cli = pkgs.callPackage ./pkgs/amcdx-video-patcher-cli { };
  cxadc = pkgs.callPackage ./pkgs/cxadc { kernel = pkgs.linuxPackages.kernel; };
  cxadc-vhs-server = pkgs.callPackage ./pkgs/cxadc-vhs-server { useFlacSox = true; };
  domesdayduplicator = pkgs.callPackage ./pkgs/domesdayduplicator { };
  ltfs = pkgs.callPackage ./pkgs/ltfs { };
  misrc-extract = pkgs.callPackage ./pkgs/misrc-extract { };
  pyhht = pkgs.python3.pkgs.callPackage ./pkgs/pyhht { };
  qwt = pkgs.callPackage ./pkgs/qwt { useQt6 = false; };
  stfs = pkgs.callPackage ./pkgs/stfs { };
  tbc-video-export = pkgs.python3.pkgs.callPackage ./pkgs/tbc-video-export { };
  #tzpfms = pkgs.callPackage ./pkgs/tzpfms { };
  vapoursynth-bwdif = pkgs.callPackage ./pkgs/vapoursynth-bwdif { };
  vapoursynth-neofft3d = pkgs.callPackage ./pkgs/vapoursynth-neofft3d { };
  vapoursynth-vsrawsource = pkgs.callPackage ./pkgs/vapoursynth-vsrawsource { };
  vhs-decode-auto-audio-align = pkgs.callPackage ./pkgs/vhs-decode-auto-audio-align { };
  vhs-decode = pkgs.callPackage ./pkgs/vhs-decode { inherit qwt; useQt6 = false; };
}
