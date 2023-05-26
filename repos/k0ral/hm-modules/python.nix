{ config, lib, pkgs ? import <nixpkgs> { }, ... }:
with lib;

let
  cfg = config.module.dev.python;
in {
  options.module.dev.python = {
    enable = mkEnableOption "Python module";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      poetry
      python3
      python3Packages.black
      python3Packages.isort
      python3Packages.mypy
      python3Packages.python-lsp-server
    ];

    programs.pylint.enable = true;
  };
}

