{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "b6eeaa6f90344b19543cff897719d40b2282428f";
  sha256 = "sha256-45TSTqUvoVO087s49j5iI1Hckljel19TAGSfiYmO4Qw=";
  version = "unstable-2026-09-25";
  branch = "staging";
}
