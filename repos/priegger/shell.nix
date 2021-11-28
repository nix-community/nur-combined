let
  sources = import ./nix/sources.nix;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  name = "nur-packages";

  buildInputs = with pkgs; [
    cachix
    niv
    nixpkgs-fmt
    shellcheck
  ];
}
