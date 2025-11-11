# Development shell for running update scripts
{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    # Tools commonly needed by update scripts
    git
    nix
    cacert
    nix-update
    # Add other tools your update scripts might need
  ];

  # Make sure update scripts can find the repository root
  shellHook = ''
    export NIX_PATH="nixpkgs=${pkgs.path}"
  '';
}
