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
  hash = "sha256-rOjNYSt/fPOlgeMvB3rA/+g/9I2CHkH986q3LddfO/c=";
  os = "linux";
  arch = "arm64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
