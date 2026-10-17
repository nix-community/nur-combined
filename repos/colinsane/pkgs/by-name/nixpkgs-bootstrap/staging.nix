{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "0ab9bb3d2a6366b1215127826d1aa1881240333a";
  sha256 = "sha256-ykV0D/gd/M8cLZB0+bXbiT2zQLDrunHFoV80JypZBak=";
  version = "unstable-2026-10-15";
  branch = "staging";
}
