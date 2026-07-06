{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0344b2eec2bd8f21788347616f5294998970b774";
  sha256 = "sha256-zAHDCarkliEC8YVzfuXLD5nGDShxEctEn22PKD4Lv9U=";
  version = "unstable-2026-07-05";
  branch = "staging-next";
}
