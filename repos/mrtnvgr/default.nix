{ pkgs ? import <nixpkgs> { } }:
let
  p = pkgs.callPackage;
in rec {
  # Soundfonts
  soundfont-touhou = p ./pkgs/soundfonts/touhou { };

  # Games (native)
  celeste-classic-2 = p ./pkgs/games/native/celeste-classic-2 { };

  # Heavily modified version of @lucasew's `wrapWine` package.
  # https://github.com/lucasew/nixcfg/blob/047c4913e9dceedd4957fb097bbf4803e5278563/nix/pkgs/wrapWine.nix
  mkWineEnv = p ./pkgs/wine-nixified/mkWineEnv.nix { };
  mkWineApp = p ./pkgs/wine-nixified/mkWineApp.nix { inherit mkWineEnv; };

  # Games (wine)
  celeste = p ./pkgs/games/wine/celeste { inherit mkWineApp; };
  celesteMods = p ./pkgs/games/wine/celeste/mods.nix { };

  # Fetchers
  # note: zip suffix doesn't mean that only zip archives are supported,
  #       so that's why gz here is like an generic term for compression algorithms
  # source: https://www.reddit.com/r/NixOS/comments/kqe57g/comment/gi3uii6
  #         https://discourse.nixos.org/t/fetchurl-with-compressed-files/39823
  # TODO: add support for .gz, ...
  fetchzip-gz = p ./pkgs/fetchers/fetchzip-gz { };
  fetchurl-gz = p ./pkgs/fetchers/fetchurl-gz { };

  # Audio
  bitwig-custom = p ./pkgs/audio/bitwig-custom/default.nix { };

  TAL-NoiseMaker = p ./pkgs/audio/TAL-NoiseMaker { };
  TyrellN6 = p ./pkgs/audio/tyrelln6 { };
  neural-amp-modeler-lv2 = p ./pkgs/audio/neural-amp-modeler-lv2 { };

  distrho-ports-vst3 = (pkgs.distrho-ports.override {
    buildLV2 = false;
    buildVST2 = false;
  }).overrideAttrs { name = "distrho-ports-vst3"; };

  vitalium-vst3 = (distrho-ports-vst3.override {
    plugins = [ "vitalium" ];
  }).overrideAttrs { name = "vitalium-vst3"; };

  TAL-plugins-vst3 = (distrho-ports-vst3.override {
    plugins = [ "tal-reverb" "tal-reverb-2" "tal-reverb-3" "tal-filter-2" "tal-dub-3" "tal-vocoder-2" ];
  }).overrideAttrs { name = "TAL-plugins-vst3"; };

  luftikus-vst3 = (distrho-ports-vst3.override {
    plugins = [ "luftikus" ];
  }).overrideAttrs { name = "luftikus-vst3"; };

  LUFSMeter-vst3 = (distrho-ports-vst3.override {
    plugins = [ "LUFSMeter" ];
  }).overrideAttrs { name = "LUFSMeter-vst3"; };

  surge-XT-vst3 = (pkgs.surge-XT.override {
    buildLV2 = false;
    buildCLAP = false;
    buildStandalone = false;
  }).overrideAttrs { name = "surge-XT-vst3"; };

  lsp-plugins-vst3 = (pkgs.lsp-plugins.override {
    buildVST2 = false;
    buildCLAP = false;
    buildLV2 = false;
    buildLADSPA = false;
    buildJACK = false;
    buildGStreamer = false;
  }).overrideAttrs { name = "lsp-plugins-vst3"; };

  artworks = p ./pkgs/audio/artworks { };
  nam-trainer = p ./pkgs/audio/nam-trainer { };

  # Media
  obs-studio-plus = (pkgs.wrapOBS {
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs
      obs-backgroundremoval
      obs-pipewire-audio-capture
      obs-vaapi
      obs-vkcapture
    ];
  });
}
