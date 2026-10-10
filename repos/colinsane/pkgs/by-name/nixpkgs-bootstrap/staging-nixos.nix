{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "a43db357fb88c78803981fe0992c8e2970020aa6";
  sha256 = "sha256-dYadBSzbYb1oE2uFZxDkrbk/AM6/ecQ1cxPirq5yEVY=";
  version = "unstable-2026-10-09";
  branch = "staging-nixos";
}
