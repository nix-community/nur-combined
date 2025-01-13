{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "6bd054ba85fe0d84f803bc3c16505a9e0738c859";
  sha256 = "sha256-o1GUu1vpD+oIfXor4e0p1rfNo/DBvdp4VUh/L4zevy4=";
  version = "0-unstable-2025-01-13";
  branch = "staging";
}
