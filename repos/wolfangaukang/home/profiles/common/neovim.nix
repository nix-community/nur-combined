{ pkgs
, neovim-pkg ? pkgs.neovim-unwrapped
, extra-plugins ? [ ]
}:

let
  defaultPlugins = (with pkgs.vimPlugins; [
    vim-nix
    vim-nixhash
  ]);

in {
  programs.neovim = {
    enable = true;
    package = neovim-pkg;
    plugins = defaultPlugins ++ extra-plugins; 
    viAlias = true;
  };
}
