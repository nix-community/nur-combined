{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "3d310dfd9b987b8676083fe8fef149e257de905c";
  sha256 = "sha256-/dSOoGbBsC4MxBsZ6p64OoNWkZnLz1U+iVcnCpPkhu8=";
  version = "0-unstable-2024-11-19";
  branch = "staging";
}
