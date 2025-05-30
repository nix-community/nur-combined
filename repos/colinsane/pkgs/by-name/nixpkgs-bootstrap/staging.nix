{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "58e8d8714792eb9868bb7ae41f52722e5b30d314";
  sha256 = "sha256-Xfy7X7IVxLTh1KF5o9nQbxLxLk5cW26zE46w4TeK1Hk=";
  version = "unstable-2025-05-29";
  branch = "staging";
}
