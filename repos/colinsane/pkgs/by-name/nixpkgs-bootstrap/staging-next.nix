{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "97c0c40475370bf4b2f396a792cff28cf0d31d46";
  sha256 = "sha256-aSxWiyox3kqiS7DxWhTXPue0G8Pzl4zMnrDGudJVGac=";
  version = "unstable-2026-06-19";
  branch = "staging-next";
}
