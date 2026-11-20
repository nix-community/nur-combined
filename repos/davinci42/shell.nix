{
  pkgs ? (builtins.getFlake (toString ./.)).inputs.nixpkgs.legacyPackages.${builtins.currentSystem},
}:
pkgs.mkShell {
  packages = with pkgs; [
    (python3.withPackages (packages: [ packages.websocket-client ]))
    just
    nix-update
    nixfmt
    statix
    deadnix
    ruff
    basedpyright
    git
    gh
  ];
}
