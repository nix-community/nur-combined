{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "fea626d2983c1fe88932013222a44f8e09645f76";
  sha256 = "sha256-OPL2nbYRjzD3gPa/oPMxX/CSYNeTxiQGpr3KJtwe9VU=";
  version = "0-unstable-2024-12-20";
  branch = "staging";
}
