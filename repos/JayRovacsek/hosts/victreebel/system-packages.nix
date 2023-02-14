{ config, pkgs, ... }:
let
  inherit (pkgs) system;
  inherit (pkgs.nur.repos.JayRovacsek) trdsql-bin;
in { environment.systemPackages = with pkgs; [ agenix trdsql-bin ]; }
