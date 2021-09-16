{ pkgs ? import <nixpkgs> { }
, sources ? import ./nix/sources.nix { }
}:

pkgs.mkShell {
  buildInputs = [
    pkgs.nix-update
    pkgs.jq
    (pkgs.callPackage sources.nix-eval-jobs { })
  ];
}
