{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "fe1cfd5b60d46aeb55bde7be5b65063080504303";
  sha256 = "sha256-iytWosR4Yxo7/3dOwPOMnEHot5Z/+hRXG0L14hj3a3w=";
  version = "unstable-2025-12-12";
  branch = "staging-next";
}
