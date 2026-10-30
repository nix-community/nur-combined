{
  nixpkgs_pkgs ? { },
  callPackage,
}:
# compatibility for nixos-26.05
nixpkgs_pkgs.ffmpeg_9 or (callPackage ../../../pkgs/ffmpeg/default.nix { }).ffmpeg_9
