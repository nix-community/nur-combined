{ dockerTools }:
let
  image = "docker.io/linuxserver/ffmpeg:8.1.2@sha256:ea8d6dc9ed6eae9b19bcb055e5ea44716a8cf24688887517dc2362cdf5767289";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-NOz7QtBDLIqbMXljRaP1PsP1BZEra55fI8gLLlbfiSI=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
