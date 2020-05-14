with { pkgs = import ./nix { }; };
pkgs.mkShell {
  name = "nur-packages";

  buildInputs = with pkgs; [
    cachix
    niv
    nixpkgs-fmt
  ];
}
