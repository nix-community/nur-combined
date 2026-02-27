{ pkgs }:
let
  image = "docker.io/linuxserver/ffmpeg:8.0.1@sha256:211841bb80a0d1faccbe7547ac5034ec02b94d5dd2a4128468006e7052662068";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(pkgs.dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-a4EFTOErHXxmzetxBkZCbAglfCcJ/eH8LwsgWtKTePo=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
