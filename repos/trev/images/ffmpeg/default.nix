{ pkgs }:
let
  image = "docker.io/linuxserver/ffmpeg:8.0.1@sha256:8c3243228f206d91f0be98df680d1bb3675e4665284caa7300f9644a84d2ffd7";
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
