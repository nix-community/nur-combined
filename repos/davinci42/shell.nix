{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    just
    nix-update
    nixfmt
    statix
    deadnix
    ruff
    basedpyright
    git
    gh
    act
    (python3.withPackages (packages: [ packages.websocket-client ]))
  ];
}
