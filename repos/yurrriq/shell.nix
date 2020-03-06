{ pkgs ? import ./nix/nixpkgs.nix }:

pkgs.mkShell {
  buildInputs =
    with pkgs; (
      [
        cargo
        git
        gnumake
        gnupg
        python3
        niv
        stow
      ]
      ++ (
        with nodePackages; [
          node2nix
        ]
      ) ++ (
        with python3Packages; [
          pre-commit
          yamllint
        ]
      )
    );
}
