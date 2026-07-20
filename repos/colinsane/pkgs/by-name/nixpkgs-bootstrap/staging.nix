{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "93c2daee52a83034f18d1af3ec0d554bcc78aea0";
  sha256 = "sha256-4te2CHSr8yJkXFJCUJkLrApf6ZbhXuzZNU9eza8OtIw=";
  version = "unstable-2026-07-19";
  branch = "staging";
}
