{ pkgs }:
let
  image = "docker.io/nixos/nix:2.33.3@sha256:c2f7db70a432d00c6759af108ff4fbc74a4c00e2d4517162e72338e7b9449c1f";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(pkgs.dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-sl1cbGT0ok+4IgY2m32M7UFb2QLIB5HkDLXUBvV0tOw=";
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
