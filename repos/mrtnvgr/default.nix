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
  js_ReaScriptAPI = p ./pkgs/audio/js_ReaScriptAPI { };

  # OneTrick-KEYS = p ./pkgs/audio/OneTrick-KEYS { };
  TAL-NoiseMaker = p ./pkgs/audio/TAL-NoiseMaker { };

  tone3000-bin = p ./pkgs/audio/tone3000-bin { };

  nam-trainer = p ./pkgs/audio/nam-trainer { };

  convert-gig-file = p ./pkgs/convert-gig-file { };

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
