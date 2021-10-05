let pkgs = import ./pkgs.nix;
in with pkgs; mkShell {
  buildInputs = [ qchem.psi4 ];
}

