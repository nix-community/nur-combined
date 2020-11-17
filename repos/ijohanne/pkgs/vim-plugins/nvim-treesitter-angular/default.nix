{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  pname = "nvim-treesitter-angular";
  version = "master";
  src = pkgs.fetchFromGitHub {
    inherit (sources.nvim-treesitter-angular) owner repo rev sha256;
  };
}
