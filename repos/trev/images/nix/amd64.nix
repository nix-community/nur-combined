{ dockerTools }:
let
  image = "docker.io/nixos/nix:2.36.0@sha256:746280551ddc1c72177d1a597c05eacac86dfaa18d5d649bf86411278bcd5470";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-GpYGNmcwXgm8ERIuJvOOTu5tG+KUSj9Ers1XMcf25ko=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
