{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "19daa683448d301912d041a865cd7e8e2dbbfaf9";
  sha256 = "sha256-xKUgAnr1fQf1j428KH9MYCB5lR6OLLdFQaS8MV+bP70=";
  version = "0-unstable-2024-11-22";
  branch = "staging-next";
}
