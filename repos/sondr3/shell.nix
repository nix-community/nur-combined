with import <nixpkgs> { };

pkgs.mkShell {
  name = "sondr3-nix";
  buildInputs = with pkgs; [ haskellPackages.niv hugo lefthook ];
}
