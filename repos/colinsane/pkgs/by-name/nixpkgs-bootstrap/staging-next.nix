{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "5fdb3bc2f497ce678db797a5a36d6430695031cb";
  sha256 = "sha256-H3ORxeTU5hXNxooliPYgdxUhwyUnnr9lCflLZ9gv7Jc=";
  version = "unstable-2026-07-10";
  branch = "staging-next";
}
