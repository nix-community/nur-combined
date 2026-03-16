{ dockerTools }:
let
  image = "docker.io/nixos/nix:2.34.1@sha256:1d59121e0c361076b4f23c158d236702f2f045b3b477b51075b81ceb6188d34a";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-3JuySksPwUoEnew9n8MvzM8JxujD+DJuqDKkGK4omBc=";
  os = "linux";
  arch = "arm64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
