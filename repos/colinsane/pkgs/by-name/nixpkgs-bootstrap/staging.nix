{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "259a3d71dcaf26fb290888bf5ffec8cff73f7322";
  sha256 = "sha256-DJNK7MTwU4uSAP442UD16JH31rn3Og15XKHs+M8/Az4=";
  version = "unstable-2026-09-03";
  branch = "staging";
}
