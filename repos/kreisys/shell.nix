{ pkgs ? import <nixpkgs> {} }:

let
  env = pkgs.buildEnv {
    name = "all-packages";
    paths = with pkgs.lib; collect isDerivation (import ./non-broken.nix { inherit pkgs; });
  };
in pkgs.mkShell {
  buildInputs  = [ env ];
}
