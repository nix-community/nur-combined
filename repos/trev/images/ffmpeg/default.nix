{ pkgs }:
let
  image = "docker.io/linuxserver/ffmpeg:8.0.1@sha256:d1bd4cfa5887ee080f79cd549c98a30f3c4d1ce50253d3517e856f4fa9b541cf";
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
