{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  name = "neovim-treesitter";
  src = pkgs.fetchFromGitHub {
    inherit (sources.nvim-treesitter) owner repo rev sha256;
  };
}
