{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "66573a60acc94d893af6559d4d2ee8682c38d0c7";
  sha256 = "sha256-fSdUzfUR0ynAjrGAjVk8HzB+ZesCZf1dDZ96Wv4HrYQ=";
  version = "unstable-2026-06-20";
  branch = "staging-next";
}
