{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "467564d6c719f05adff8a40f4c16c519e17d5412";
  sha256 = "sha256-BIztsTkbMdVdr8jgU9+HsSMt4RTco8bYHoSeaNkenNI=";
  version = "unstable-2026-08-21";
  branch = "staging";
}
