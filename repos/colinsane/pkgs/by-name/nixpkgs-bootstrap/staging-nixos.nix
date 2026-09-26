{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "6f1ff1ac54286c25026f035f43509bcaa526968b";
  sha256 = "sha256-3yv2RcXV1EU/a3hK+WHjgFdQEwmAlOiM2NVA+cgWlT4=";
  version = "unstable-2026-09-26";
  branch = "staging-nixos";
}
