let
  sources = import ./npins;
  pkgs = import sources.nixpkgs { };
in
pkgs.mkShell {
  name = "nur-packages";

  buildInputs = with pkgs; [
    cachix
    nixpkgs-fmt
    npins
    shellcheck
  ];
}
