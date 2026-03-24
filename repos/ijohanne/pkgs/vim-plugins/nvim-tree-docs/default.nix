{ pkgs, sources }:
pkgs.vimUtils.buildVimPlugin {
  name = "nvim-tree-docs-master";
  version = "master";
  pname = "nvim-tree-docs";
  src = sources.nvim-tree-docs;
  doCheck = false;
}
