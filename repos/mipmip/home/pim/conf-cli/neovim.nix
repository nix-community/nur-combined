{ config, pkgs,unstable, ... }:

{
  programs.neovim = {
    enable = true;
    #package = unstable.neovim;
  };

  home.packages = [
    pkgs.nil
  ];

#  programs.neovim = {
#    plugins = with pkgs.vimPlugins; [
#      nvim-treesitter.withAllGrammars
#    ];
#
#    extraConfig = ''
#      "colorscheme NeoSolarized
#      "set termguicolors
#      "let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
#      "let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
#      "set background=light
#
#      "set runtimepath^=~/.vim runtimepath+=~/.vim/after
#      "let &packpath = &runtimepath
#      "source ~/.vim/vimrc
#    '';
#  };
}
