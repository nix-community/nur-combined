{ pkgs }:
let
  image = "docker.io/nixos/nix:2.33.1@sha256:d5cce2440bda1f966357732c06d86cb92368069fb52dfb6b2bae8725eea488a5";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(pkgs.dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-4+99v7Jej0dY0zv8iJLtFiulCsw90ZnGwtjTaGu2L+c=";
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
