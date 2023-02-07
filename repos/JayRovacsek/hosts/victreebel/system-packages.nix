{ config, pkgs, ... }:
let inherit (pkgs) system;
in { environment.systemPackages = with pkgs; [ agenix ]; }
