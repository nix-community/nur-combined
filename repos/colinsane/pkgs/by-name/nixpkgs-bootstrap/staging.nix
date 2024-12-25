{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "c1c11568946b9992666302f62490f275a2381660";
  sha256 = "sha256-JX8XcF2U6K7nAm1q+GphEiq1g+9IJk0wNAu48JW40Q8=";
  version = "0-unstable-2024-12-22";
  branch = "staging";
}
