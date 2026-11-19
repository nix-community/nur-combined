{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    devenv
    just
  ];

  shellHook = ''
    git remote update -p
    echo ""
    echo "================================================================"
    echo "================================================================"
    echo ""
  '';
}
