{ pkgs ? import <nixpkgs> { }
}:

pkgs.mkShell {
  buildInputs = [
    pkgs.nix-update
    pkgs.jq
  ];
}
