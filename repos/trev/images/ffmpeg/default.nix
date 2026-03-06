{ pkgs }:
let
  image = "docker.io/linuxserver/ffmpeg:8.0.1@sha256:85a858ad705ad4a045c27a6a7fbade04ae79311c91b1c1c5e582cc08bf3f1fe6";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(pkgs.dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-HmHq5v1hZuY8MtFx4XdciUg1JCVdiDSsP6gkjJEIJh4=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
