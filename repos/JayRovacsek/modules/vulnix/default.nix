{ config, pkgs, ... }: { environment.systemPackages = with pkgs; [ vulnix ]; }
