{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  pname = "nvim-tree-docs";
  version = "master";
  src = pkgs.fetchFromGitHub {
    inherit (sources.nvim-tree-docs) owner repo rev sha256;
  };
}
