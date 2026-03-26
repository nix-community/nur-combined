{ dockerTools }:
let
  image = "docker.io/nixos/nix:2.34.4@sha256:0b1530edf840d9af519c7f3970cafbbed68d9d9554a83cc9adc04099753117e1";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-rQM5DFlXlfhsc6p2TmAlOdCDDuoTsPrFi07M15BPU4w=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
