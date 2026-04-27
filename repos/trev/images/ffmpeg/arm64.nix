{ dockerTools }:
let
  image = "docker.io/linuxserver/ffmpeg:8.0.1@sha256:c374c5cba072160f2f8d0c1c1cf292b49681a22f71acbb8830f94c50fa5bfedf";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-/0kj+vFwOJxNVW5zuLgmEe9oXzYyOKOVrotnL0+K30Y=";
  os = "linux";
  arch = "arm64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
