{ dockerTools }:
let
  image = "docker.io/linuxserver/ffmpeg:8.0.1@sha256:73a527e064e19aff06b470b192b522cab8749ca3915f0e71cd70af41299b8809";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-2DKxzS4lZuQJQ9frqC19eTQ/VcdPqPKCt/IH+5dp3n8=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
