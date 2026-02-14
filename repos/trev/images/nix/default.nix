{ pkgs }:
let
  image = "docker.io/nixos/nix:2.33.3@sha256:37eafc36261a1efaf9b17f3e0cfb450be00893087e3797bd1e3be4df68dfe6fe";
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
