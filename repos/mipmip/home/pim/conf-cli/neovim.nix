{ config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    plugins = with pkgs.vimPlugins; [
      vim-javascript
      vim-jsx-pretty
      NeoSolarized
      fzf-lsp-nvim
      nerdtree
    ];

    extraConfig = ''

colorscheme NeoSolarized
set termguicolors
let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
      set background=light

    '';
  };
}
