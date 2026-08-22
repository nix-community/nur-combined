{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "4b68493e3812d2bba9fe6a7714da7b9b89160399";
  sha256 = "sha256-0qUnj244g0noha4caeC4sbtj9dI7tq9P6QILrG5TUik=";
  version = "unstable-2026-08-21";
  branch = "staging-next";
}
