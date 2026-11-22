{
  mkNixpkgs ? import ./mkNixpkgs.nix { },
}:
mkNixpkgs {
  rev = "64e72bb889b23a252807d1e8d3a1c4406eae8283";
  sha256 = "sha256-sdASeM9KVwT6H6+hSy3j8ImyxZSjM5C06EyGhuG64+k=";
  version = "unstable-2026-11-21";
  branch = "staging";
}
