{ dockerTools }:
let
  image = "docker.io/linuxserver/ffmpeg:8.1.2@sha256:282f8c023eb24cafc8fbd92e35a35627815cd1c8b183beddf6e29b9a93329435";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-YIt3P4pwZCG4prhp4QW7iluc6Jqsl+2ZSeLFgAP6RGE=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
