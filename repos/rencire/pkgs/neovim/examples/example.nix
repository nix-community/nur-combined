{ systempkgs ? import <nixpkgs> {} # only importing this so we can use `stdenv.isDarwin`
 ,sources ? import ./nix/sources.nix
  # If on mac, get darwin channel
 ,pkgs ? import (if systempkgs.stdenv.isDarwin then sources.nixpkgs-darwin else sources.nixpkgs) {} 
 ,neovim ? import sources.neovim-nix { lib = pkgs.lib; neovim = pkgs.neovim; }
}:

neovim.override {
  withNodeJs = true;
  configure = with pkgs.vimPlugins; {
    customRC = ''
    "from customrc
    '';
    packages = {
      a = {
        start = [
          {
            plugin = vim-tmux-navigator;
            vimrc = ''
              "package a. start. plugin 1 
            '';
          }
        ];
        opt = [
          {
            plugin = vim-commentary;
            vimrc = ''
            "package a. opt. plugin 2
            '';
          }
        ];
      };
      b = {
        start = [
          syntastic
          {
            plugin = nerdtree;
            vimrc = ''
            "package b. start. plugin 3
            '';
          }
        ];
        opt = [
          {
            plugin = tagbar;
            vimrc = ''
            "package b. opt. plugin 4
            '';
          }
        ];
      };
    };
    plug.plugins = [ 
      vim-gitgutter
      { 
        plugin = ale; 
        vimrc = '' 
        "vim plug. plugin 5
        '';
      }
    ];
  };
}


