{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "0e4036ae2669b5b25f9b74695051dc1541037cc0";
  sha256 = "sha256-fFXlKTCAfyXReY/UxVAALKmpByufzD/9SVnGbIcD0GA=";
  version = "0-unstable-2025-01-05";
  branch = "staging";
}
