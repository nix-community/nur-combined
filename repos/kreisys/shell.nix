{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = with pkgs.lib; collect isDerivation (import ./non-broken.nix { inherit pkgs; });
}
