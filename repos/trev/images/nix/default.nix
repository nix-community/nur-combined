{ pkgs }:
let
  image = "docker.io/nixos/nix:2.33.2@sha256:c6ebd12d96b3374ee15e3986c15aa43f5e49310634f17afcaaf4dafe4f6732b2";
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
