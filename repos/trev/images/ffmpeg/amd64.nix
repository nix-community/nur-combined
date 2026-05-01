{ dockerTools }:
let
  image = "docker.io/linuxserver/ffmpeg:8.0.1@sha256:c72eaf699cb104e84c5292ee9b2a65bf3110738dec113d7cfcef02d7bc21b056";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-u00kqg/+RIiAsH+TihpeDgD1QbmC1lObd8IFsvyAbNw=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
