{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "9ce4c6249ea41ae5e8a732257f83f55eec40c7fb";
  sha256 = "sha256-GMbBZVcjSEHkvUlPmZT4r1DAytuAO86doBfJa7ZhyI4=";
  version = "unstable-2026-08-08";
  branch = "staging";
}
