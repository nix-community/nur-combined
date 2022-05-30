{ config, lib, pkgs, ... }:

{
  environment.sessionVariables = {
    EDITOR = "vim";
  };

  environment.systemPackages = with pkgs; [
    tmux
    wget
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
