{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  pname = "nvim-treesitter-refactor";
  version = "master";
  src = pkgs.fetchFromGitHub {
    inherit (sources.nvim-treesitter-refactor) owner repo rev sha256;
  };
}
