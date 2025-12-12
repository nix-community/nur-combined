{ pkgs }:
let
  image = "docker.io/nixos/nix:2.33.0@sha256:081b65e50a5c4e6ef4a9094a462da3b83ff76bfec70236eb010047fcee36e11c";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(pkgs.dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-YnQBYya44dDZxwpRLUhFbFndy3UwhNFsIdV6BBeGFTI=";
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
