{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "aaed808ae478e7747cf847876ccde634236b9de8";
  sha256 = "sha256-x+O4+TKY5sXoygvaxndLLCxIjRxaN4hOeWRl/+U878k=";
  version = "unstable-2026-06-16";
  branch = "staging-next";
}
