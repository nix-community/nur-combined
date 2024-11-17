{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "dc2fbd51fd8ca113c2061350c7cffafe8739436f";
  sha256 = "sha256-h2RGNk3wD7oStAeXFDepZ6MneZ+qVgy4a4J7YqdzU/M=";
  version = "0-unstable-2024-11-16";
  branch = "staging";
}
