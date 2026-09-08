{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "8f01c55eb6efb975878cde1b6fa62d968ab04457";
  sha256 = "sha256-GapwXFWNXBRNCV1e47n40hTqJcCZEGgqfMJ+OhVXZTg=";
  version = "unstable-2026-09-07";
  branch = "staging";
}
