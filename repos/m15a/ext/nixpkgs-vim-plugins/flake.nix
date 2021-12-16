{
  description = "Nix flake of miscellaneous Vim/Neovim plugins";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = { url = "github:edolstra/flake-compat"; flake = false; };
  };

  outputs = { self, nixpkgs, flake-utils, ... }: {
    overlay = import ./overlay.nix;
  } // (flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ self.overlay ];
    };

    update-vim-plugins = pkgs.callPackage ./pkgs/update-vim-plugins.nix {};
  in {
    packages = {
      inherit (pkgs) vimExtraPlugins;
    };

    apps = {
      update-vim-plugins = {
        type = "app";
        program = "${update-vim-plugins}/bin/update-vim-plugins";
      };
    };

    devShell = pkgs.mkShell {
      inputsFrom = [
        update-vim-plugins
      ];
      buildInputs = [
      ] ++ (with pkgs.luajit.pkgs; [
        readline
      ]);
    };
  }));
}
