{
  pkgs,
}:

pkgs.mkShell {
  packages = with pkgs; [
    flake-show-ng
    just
    just-lsp
    nixd
    nixfmt
    nixfmt-tree
    rom
  ];
}
