{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b7d7ea22be7c9d5737e430d1a29553cde9ab4037";
  sha256 = "sha256-tN3zieULzJL9lj8Yy+mKpsq6t4UfPgk0tsuJGDdS+fE=";
  version = "unstable-2026-06-19";
  branch = "staging";
}
