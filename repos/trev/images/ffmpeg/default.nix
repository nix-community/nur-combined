{ pkgs }:
let
  image = "docker.io/linuxserver/ffmpeg:8.0.1@sha256:9bd9dd171ca695ebf6c747658be587eeeaaa5c7274c3ad406490da24eea4c053";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(pkgs.dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-yYTK1TAwx0NL0+WsLCVHg6FUC3AxyLFVANhM9FPCvsw=";
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
