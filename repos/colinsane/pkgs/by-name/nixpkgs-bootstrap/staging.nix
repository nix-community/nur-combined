{
  mkNixpkgs ? import ./mkNixpkgs.nix {}
}:
mkNixpkgs {
  rev = "4e1d4f49f2aeb5fe0a5a9694bfb96dac99045149";
  sha256 = "sha256-EBlotppgK4cIoadWWnscE23tmYD47nbvgaOo2vHEQvQ=";
  version = "0-unstable-2024-12-29";
  branch = "staging";
}
