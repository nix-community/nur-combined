{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "f2b3ac2ee724ad770ac7456374fa79eede152b4b";
  sha256 = "sha256-lGJpgdD/la2VRx3vvO4OtWoIIBdh4+o/8SlMMOisMWQ=";
  version = "unstable-2026-09-26";
  branch = "staging-next";
}
