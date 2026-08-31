{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "31ec35835542b62f5a0f6a8cc9499d26e7a9463f";
  sha256 = "sha256-bSeLdyJkTu64Wk3FUIY2nbN67QTaapD/Ze4h0AVq+DU=";
  version = "unstable-2026-08-30";
  branch = "staging";
}
