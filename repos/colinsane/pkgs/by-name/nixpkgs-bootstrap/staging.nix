{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "206fd6070d31a63349fc0b6542376d076a7fa3d6";
  sha256 = "sha256-JXtlfHtWrkDlua6e6s3jrMzOKB8J41UdLmdC9Pu6V6o=";
  version = "unstable-2026-07-05";
  branch = "staging";
}
