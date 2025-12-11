{
  mkNixpkgs ? import ./mkNixpkgs.nix {},
}:
mkNixpkgs {
  rev = "74edd868c779f294666c6f99ca1caf2d6c65f911";
  sha256 = "sha256-hc+tS/A0d+C89pGWjiaSypr0h0wzpj15+4nNYEa9hKE=";
  version = "unstable-2025-12-11";
  branch = "staging-next";
}
