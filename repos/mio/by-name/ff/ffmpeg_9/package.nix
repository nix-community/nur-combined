{ callPackage }:
# compatibility for older nixos
(callPackage ../../../pkgs/ffmpeg/default.nix { }).ffmpeg_9
