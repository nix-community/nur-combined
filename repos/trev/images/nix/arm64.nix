{ dockerTools }:
let
  image = "docker.io/nixos/nix:2.35.5@sha256:9305de534abed691d0f569502a4962a3a072ea8e888502c453ecfe35ae182867";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-TrgzTrCQCqGq6n7gjR4DApyo3hw8UuM02PHD09UaMDE=";
  os = "linux";
  arch = "arm64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
