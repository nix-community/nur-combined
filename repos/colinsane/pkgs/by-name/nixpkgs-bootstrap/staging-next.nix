{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "908e8572df13e687e075e9d69a1660ffcf2ee6f7";
  sha256 = "sha256-MwVPit6BEc2EFShZXTjZ+nx4IRDmtBUPg3MRAEBs/y0=";
  version = "0-unstable-2024-12-08";
  branch = "staging-next";
}
