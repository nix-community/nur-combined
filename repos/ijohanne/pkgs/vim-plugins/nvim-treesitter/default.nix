{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  pname = "nvim-treesitter";
  version = "master";
  src = pkgs.fetchFromGitHub {
    inherit (sources.nvim-treesitter) owner repo rev sha256;
  };
}
