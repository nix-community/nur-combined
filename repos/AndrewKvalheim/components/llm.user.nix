{ config, lib, pkgs, ... }:

let
  inherit (config) system;
  inherit (lib) mkIf;
in
mkIf system.host.features.llm {
  home.packages = with pkgs; [
    alpaca
    jan
    llmfit
  ];
}
