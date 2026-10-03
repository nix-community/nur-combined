{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "adfb7fc9babf28b3ee0949d8c1f4331cb374fb97";
  sha256 = "sha256-mYAmB6esqSvO8+awRWzxCpTK5z2Adwh+9sqDCrBSd6U=";
  version = "unstable-2026-10-02";
  branch = "staging-next";
}
