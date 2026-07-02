{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "c5a80d8625687a4dae72aa73fae894c2b0dffdb8";
  sha256 = "sha256-zJC9XCJyiPq8Q6OyLTSQ/OouR2Yp60PtfrggiMAYaWA=";
  version = "unstable-2026-07-01";
  branch = "staging-next";
}
