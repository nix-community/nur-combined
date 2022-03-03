{ global, pkgs, config, self, lib, ...}:
let
  inherit (self) inputs outputs;
  inherit (lib) mkDefault;
  inherit (global) environmentShell;
in
{
  home.packages = with pkgs; [
    youtube-dl # video downloader
    file # what file is it?
    neofetch # system info, arch linux friendly
    comma # like nix-shell but more convenient
    fzf # file finder and terminal based dmenu
    ffmpeg # video converter
    send2kindle
  ];

  home.stateVersion = mkDefault "20.03";

  home.file.".dotfilerc".text = ''
    #!/usr/bin/env bash
    ${environmentShell}
  '';
  programs = {
    tmux.enable = true;
    git = {
        enable = true;
        userName = global.username;
        userEmail = global.email;
        package = mkDefault pkgs.gitMinimal;
    };
  };
}
