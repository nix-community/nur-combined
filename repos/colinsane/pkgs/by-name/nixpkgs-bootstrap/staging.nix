{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "40211d0f32aece6d7454a93f4a66147d19f04721";
  sha256 = "sha256-vsDAWCpvlW37CDSLEp3F5GOfuIuGpG8H75gxJ3V9OCk=";
  version = "unstable-2026-06-20";
  branch = "staging";
}
