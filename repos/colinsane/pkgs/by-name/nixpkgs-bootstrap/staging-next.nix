{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "6793b353338d2bfd6a95bef48e4bc78f6dc24436";
  sha256 = "sha256-OqJKH1Rnbb/nO9ISlfDl47G1vvolHK1KiOcwhxAZ+7A=";
  version = "0-unstable-2025-02-07";
  branch = "staging-next";
}
