{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "fb2cbe17be2f653607b14797e1a67ef383839ecd";
  sha256 = "sha256-2CXl9N0h79SGRGiJktkyfJMpKhXVb2VfRJANy02uOfM=";
  version = "unstable-2026-09-22";
  branch = "staging-nixos";
}
