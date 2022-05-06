{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    package = pkgs.neovim-unwrapped;
    plugins = with pkgs.vimPlugins; [
      vim-nix
    ];
    viAlias = true;
  };
}
