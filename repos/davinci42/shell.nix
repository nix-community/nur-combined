{
  pkgs ? import <nixpkgs> { },
}:
pkgs.mkShell {
  packages = with pkgs; [
    (python315.withPackages (packages: [ packages.websocket-client ]))
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
  ];
}
