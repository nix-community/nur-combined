{ pkgs, sources }:
pkgs.vimUtils.buildVimPluginFrom2Nix {
  name = "vim-hexokinase";
  src = pkgs.fetchFromGitHub {
    inherit (sources.vim-hexokinase) owner repo rev sha256;
  };
}
