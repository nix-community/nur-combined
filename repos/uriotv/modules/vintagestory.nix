# Vintage Story NixOS Module
#
# This module provides an easy way to install Vintage Story with explicit version control.
# Both version and hash are REQUIRED - no auto-updates, full user control.
#
# Usage:
#   programs.vintagestory = {
#     enable = true;
#     version = "1.21.0";
#     hash = "sha256-90YQOur7UhXxDBkGLSMnXQK7iQ6+Z8Mqx9PEG6FEXBs=";
#   };
#
# To get hash for a new version:
#   nix-prefetch-url https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_<VERSION>.tar.gz
#   nix hash convert --hash-algo sha256 --to sri <HASH>

# This is a module factory - it takes the package path and returns a module
vintagestoryPkgPath:

{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.vintagestory;

  vintagestoryPkg = pkgs.callPackage vintagestoryPkgPath {
    inherit (cfg) version hash;
  };
in
{
  options.programs.vintagestory = {
    enable = lib.mkEnableOption "Vintage Story game";

    version = lib.mkOption {
      type = lib.types.str;
      description = ''
        The version of Vintage Story to install.
        Check https://www.vintagestory.at/download/ for available versions.
      '';
      example = "1.21.0";
    };

    hash = lib.mkOption {
      type = lib.types.str;
      description = ''
        SHA256 hash of the game archive (SRI format).

        To get the hash:
          nix-prefetch-url https://cdn.vintagestory.at/gamefiles/stable/vs_client_linux-x64_<VERSION>.tar.gz
          nix hash convert --hash-algo sha256 --to sri <HASH>
      '';
      example = "sha256-90YQOur7UhXxDBkGLSMnXQK7iQ6+Z8Mqx9PEG6FEXBs=";
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = vintagestoryPkg;
      defaultText = lib.literalExpression "pkgs.vintagestory";
      description = "The Vintage Story package to use.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
  };
}
