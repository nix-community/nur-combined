{ dockerTools }:
let
  image = "docker.io/linuxserver/ffmpeg:9.0.2@sha256:66fa8e2351fb78f9dad2c59c946be2658edcc529339320da3f2cf788312368af";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-FMp/wxJGZkY1dhirMpIPYPkLyRidHRxClqsyGGt4HCA=";
  os = "linux";
  arch = "arm64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
