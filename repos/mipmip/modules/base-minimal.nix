{ config, lib, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
    tmux
    wget
    #vim
    gitFull
  ]
  ++ (if pkgs.stdenv.isDarwin then
  [
  ]
  else
  [
    curl
    gnumake
    zsh
  ]
  );
}
