{ dockerTools }:
let
  image = "docker.io/linuxserver/ffmpeg:9.0.2@sha256:abb675ffda7047f42dfba02adcd0886b3abfca6dec332adc4da831de943989ed";
  parts = builtins.match "(.+/)(.+):(.+)@(.+)" image;
in
# https://github.com/nixos/nixpkgs/issues/445481
(dockerTools.pullImage {
  imageName = builtins.elemAt parts 0 + builtins.elemAt parts 1;
  finalImageName = builtins.elemAt parts 1;
  finalImageTag = builtins.elemAt parts 2;
  imageDigest = builtins.elemAt parts 3;
  hash = "sha256-lCEVRXigMI4m/GqTNyMANSGsTXDC4jOt+08Zy5f33hE=";
  os = "linux";
  arch = "amd64";
}).overrideAttrs
  {
    __structuredAttrs = true;
    unsafeDiscardReferences.out = true;
  }
