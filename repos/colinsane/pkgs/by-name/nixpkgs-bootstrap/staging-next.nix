{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "280c4a07750d007fae3877ec8a2d3edad4fb181b";
  sha256 = "sha256-fC0vrzFKk5yFMRYW9iTby+ecsUovKAqEjYML54Z+7ZY=";
  version = "unstable-2026-06-05";
  branch = "staging-next";
}
