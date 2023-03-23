{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    smug
    tmux
    urlview

  ];
}

