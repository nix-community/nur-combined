{ dockerTools }:
let
  image = "docker.io/linuxserver/ffmpeg:9.0.2@sha256:822d04f0b2d0c4847430f5cc90f20ea48be866bb502ece63fdeb729400bf5361";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-alVnGw0KHD9VqmALkdTE6Z15uR3HAXcc8R66dGZod54=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
