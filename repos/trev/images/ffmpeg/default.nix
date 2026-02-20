{ pkgs }:
let
  image = "docker.io/linuxserver/ffmpeg:8.0.1@sha256:3eb0fb41f860973ff20e8f3da77587930def6cd24a0eebc79f3652378f237684";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(pkgs.dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-fzhJe5F37t+8xsquRXqimrPavgVdYBLx1udjMM6rK/k=";
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
