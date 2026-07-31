{ dockerTools }:
let
  image = "docker.io/linuxserver/ffmpeg:8.1.2@sha256:38f9befcbb1ceab4980aeb6dccb5b3a9be335094967fd09a0ba3d50882632731";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-bGtk2TVmYzdSnReXracS12s/MT2VKB/92Ytr+guY6jE=";
  os = "linux";
  arch = "arm64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
