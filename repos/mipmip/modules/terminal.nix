{ config, lib, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # tmux
    tmux
    urlview

  ];
}

