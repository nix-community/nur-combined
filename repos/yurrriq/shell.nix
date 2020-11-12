{ pkgs ? import ./nix }:

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
        nixpkgs-fmt
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
