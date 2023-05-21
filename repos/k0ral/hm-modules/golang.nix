{ config, lib, pkgs ? import <nixpkgs> { }, ... }:
with lib;

let
  cfg = config.module.dev.golang;
in {
  options.module.dev.golang = {
    enable = mkEnableOption "Golang module";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      golangci-lint
      gopls
      gotestsum
      mockgen
    ];

    programs.go.enable = true;
  };
}
