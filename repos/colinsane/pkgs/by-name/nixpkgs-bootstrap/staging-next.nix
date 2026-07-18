{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "5588578240a4115b74ee488c6349c6a49bd1f3da";
  sha256 = "sha256-l3wgl8uzLbsXq0tHRFCSEfxsv3lIH7B2877OdFiCOhk=";
  version = "unstable-2026-07-18";
  branch = "staging-next";
}
