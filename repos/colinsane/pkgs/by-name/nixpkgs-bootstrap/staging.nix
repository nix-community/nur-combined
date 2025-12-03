{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "4e086aa8bea37e6d3d100061fb8be7c0759d3b3e";
  sha256 = "sha256-/awJ+c9zUMI6r5UOis9JJNKwf2NNc0nK78wPjNtKX9U=";
  version = "unstable-2025-12-02";
  branch = "staging";
}
