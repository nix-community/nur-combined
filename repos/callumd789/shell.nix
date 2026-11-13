{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    devenv
    just
  ];

  shellHook = ''
    echo ""
    echo "================================================================"
    echo "================================================================"
    echo ""
  '';
}
