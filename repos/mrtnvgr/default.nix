{ pkgs }:
let
  p = pkgs.callPackage;
in rec {
  # Soundfonts
  soundfont-touhou = p ./pkgs/soundfonts/touhou { };

  # Games (native)
  celeste-classic-2 = p ./pkgs/games/native/celeste-classic-2 { };

  # Heavily modified version of @lucasew's `wrapWine` package.
  # https://github.com/lucasew/nixcfg/blob/047c4913e9dceedd4957fb097bbf4803e5278563/nix/pkgs/wrapWine.nix
  mkWineEnv = p ./pkgs/builders/wine-nixified/mkWineEnv.nix { };
  mkWineApp = p ./pkgs/builders/wine-nixified/mkWineApp.nix { inherit mkWineEnv; };

  # Games (wine)
  celeste = p ./pkgs/games/wine/celeste { inherit mkWineApp; };
  celesteMods = p ./pkgs/games/wine/celeste/mods.nix { };

  # Fetchers
  # note: zip suffix doesn't mean that only zip archives are supported,
  #       so that's why gz here is like an generic term for compression algorithms
  # source: https://www.reddit.com/r/NixOS/comments/kqe57g/comment/gi3uii6
  #         https://discourse.nixos.org/t/fetchurl-with-compressed-files/39823
  # TODO: add support for .gz, ...
  fetchzip-gz = p ./pkgs/builders/fetchers/fetchzip-gz { };
  fetchurl-gz = p ./pkgs/builders/fetchers/fetchurl-gz { };

  # Audio
  bitwig-custom = p ./pkgs/audio/bitwig-custom/default.nix { };

  js_ReaScriptAPI = p ./pkgs/audio/js_ReaScriptAPI { };

  # OneTrick-KEYS = p ./pkgs/audio/OneTrick-KEYS { };
  TAL-NoiseMaker = p ./pkgs/audio/TAL-NoiseMaker { };
  neural-amp-modeler-lv2 = p ./pkgs/audio/neural-amp-modeler-lv2 { };

  vitalium-vst3 = (pkgs.distrho-ports.override {
    buildVST2 = false;
    buildLV2 = false;

    plugins = [ "vitalium" ];
  }).overrideAttrs { pname = "vitalium-vst3"; };

  TAL-plugins-vst2 = (pkgs.distrho-ports.override {
    buildLV2 = false;
    plugins = [ "tal-reverb" "tal-reverb-2" "tal-reverb-3" "tal-filter-2" "tal-dub-3" "tal-vocoder-2" ];
  }).overrideAttrs { pname = "TAL-plugins-vst2"; };

  luftikus-vst2 = (pkgs.distrho-ports.override {
    buildLV2 = false;
    plugins = [ "luftikus" ];
  }).overrideAttrs { pname = "luftikus-vst2"; };

  LUFSMeter-vst2 = (pkgs.distrho-ports.override {
    buildVST2 = false;
    plugins = [ "LUFSMeter" ];
  }).overrideAttrs { pname = "LUFSMeter-vst2"; };

  surge-XT-vst3 = (pkgs.surge-XT.override {
    buildLV2 = false;
    buildCLAP = false;
    buildStandalone = false;
  }).overrideAttrs { pname = "surge-XT-vst3"; };

  lsp-plugins-vst3 = (pkgs.lsp-plugins.override {
    buildVST2 = false;
    buildCLAP = false;
    buildLV2 = false;
    buildLADSPA = false;
    buildJACK = false;
    buildGStreamer = false;
  }).overrideAttrs { pname = "lsp-plugins-vst3"; };

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

  # Reaper themes
  reapertips-dark = p ./pkgs/reapertips/dark.nix { };

  cardinal-unstable-test = pkgs.cardinal.overrideAttrs {
    version = "0-unstable-1234124";

    src = pkgs.fetchFromGitHub {
      owner = "DISTRHO";
      repo = "Cardinal";
      rev = "7c589fe6114bf3103a3a6ac6da39a842fd374e97";
      fetchSubmodules = true;
      hash = "sha256-R5pCP9EIO1ZU5Io0qyYSpCShRY7d5td3xA66sGki+Lw=";
    };
  };
}
