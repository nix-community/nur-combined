{ pkgs ? import ./nix { } }:
pkgs.mkShell {
  name = "nur-packages";

  buildInputs = with pkgs; [
    cachix
    niv
    nixpkgs-fmt
    shellcheck
  ];

  NIX_PATH = "nixpkgs=https://nixos.org/channels/nixos-unstable/nixexprs.tar.xz";
}
