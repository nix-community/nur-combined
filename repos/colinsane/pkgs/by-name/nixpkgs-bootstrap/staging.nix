{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "4095dafc9aed070fffb2d6ee5ffae8ed5c05b937";
  sha256 = "sha256-kIfXVNxtJJRl6wRk8clqDpq1dF+7ciooa0IgE3DPmFk=";
  version = "unstable-2026-06-16";
  branch = "staging";
}
