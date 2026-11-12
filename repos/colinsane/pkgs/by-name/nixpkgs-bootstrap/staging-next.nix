{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b39b88a7d606f8cdca0943bf5c730fc18dd157ff";
  sha256 = "sha256-VMfQyTEGRhEGeu822ZugPawJs61QYklsFJ4p0loM+48=";
  version = "unstable-2026-11-06";
  branch = "staging-next";
}
