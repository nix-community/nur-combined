{ config ? {}, lib, pkgs, ... }:
let
  upstream = (import ~/src/nixos/nixpkgs {});
  self = (import ../../.. {});
  hm = self.hm;
in
{
  imports = lib.attrValues hm.rawModules;

  home.packages = hm.base ++ [
    pkgs.slack
    upstream.vscode
    pkgs.discord
    pkgs.vlc
  ];

  programs.crostini.enable = true;

  services.keybase.enable = true;
  services.kbfs.enable = true;

  programs.bash.enable = true;
  programs.vim = {
    enable = true;
    plugins = ["vim-airline"];
    settings = { ignorecase = true; };
    extraConfig = ''
      " airline
      let g:airline#extensions#tabline#enabled = 1
    '';

  };


  home.file = self.lib.buildDesktops [
  # {
    # name = "Slack";
    # package = pkgs.slack;
  # }
  # {
    # name = "VSCode";
    # package = pkgs.vscode;
  # }
  ];
}
