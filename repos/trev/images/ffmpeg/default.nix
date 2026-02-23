{ pkgs }:
let
  image = "docker.io/linuxserver/ffmpeg:8.0.1@sha256:96362b26bbe9ab836a619ccd49cf5258da9b2a22c8688317441aefb2bba4c6a0";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(pkgs.dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-CGhiEMsJP+BGP1OOti5uc6SIzX2Yc2Yg1sClyhTV3yc=";
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
