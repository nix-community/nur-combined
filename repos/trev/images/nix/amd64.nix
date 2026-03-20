{ dockerTools }:
let
  image = "docker.io/nixos/nix:2.34.2@sha256:cf42be9911411150ed246632633e846ee185384d97c9a8a27e8ca15ab3a7a48f";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-YJGBt9yH/r6oTV4W7koicMW4eep+RhRHRcoRJYYPDYY=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
