# nixpkgs-vim-plugins

Nix flake of miscellaneous Vim/Neovim plugins.

## Description

This flake contains Nix packages of miscellaneous Vim/Neovim plugins.
Most of them are simply not provided by the official nixpkgs.
Some of them are provided but patched in this flake, or their version/revision
in the official nixpkgs is not up to date for my use case.

Packages are automatically updated twice per week using GitHub Actions.

## Usage

### In flake

The overlay simply adds extra Vim plugins into `pkgs.vimExtraPlugins`.
Use it as you normally do, like

```nix
{
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    vim-plugins.url = "github:m15a/nixpkgs-vim-plugins";
  };
  outputs = { self, nixpkgs, flake-utils, vim-plugins, ... }:
  flake-utils.lib.eachDefaultSystem (system:
  let
    pkgs = import nixpkgs {
      inherit system;
      overlays = [ vim-plugins.overlay ];
    };
  in {
    packages = {
      my-neovim = pkgs.neovim.override {
        configure = {
          packages.example = with pkgs.vimExtraPlugins; {
            start = [
              lspactions
              vim-hy
            ];
          };
        };
      };
    };
  });
}
```

### In legacy Nix

It is handy to use `builtins.getFlake`, which was [introduced in Nix 2.4][1]. For example,

```nix
with import <nixpkgs> {
  overlays = [
    (builtins.getFlake "github:m15a/nixpkgs-vim-plugins").overlay
  ];
};
```

For Nix <2.4, use `builtins.fetchTarball` instead.

```nix
with import <nixpkgs> {
  overlays = [
    (import (builtins.fetchTarball {
      url = "https://github.com/m15a/nixpkgs-vim-plugins/archive/main.tar.gz";
    })).overlay
  ];
};
```

[1]: https://nixos.org/manual/nix/stable/release-notes/rl-2.4.html?highlight=builtins.getFlake#other-features

## Available Vim/Neovim plugins

| Plugin owner/repo | Recent commit | Nix package name |
| :- | :- | :- |
