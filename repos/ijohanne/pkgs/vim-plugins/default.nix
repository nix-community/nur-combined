{ pkgs, sources }:
{
  nvim-tree-docs = import ./nvim-tree-docs { inherit pkgs sources; };
}
