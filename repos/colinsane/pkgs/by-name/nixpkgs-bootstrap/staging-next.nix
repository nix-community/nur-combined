{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "a914ea984e18f11a27858df064e96cd45616e8e1";
  sha256 = "sha256-mz/xSAt1c42ChHWJsgzwzb6ME++97cYPW6bhsx311Ck=";
  version = "unstable-2026-10-21";
  branch = "staging-next";
}
