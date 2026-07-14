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
  hash = "sha256-QpwSnRFqCOAjoLi2GbK6743Kb84rvKnmlq0TW+udRxk=";
  os = "linux";
  arch = "arm64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
