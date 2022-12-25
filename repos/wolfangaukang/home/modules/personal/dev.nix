{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.defaultajAgordoj.dev;
  settings = import ./settings.nix { inherit pkgs; };

in
{
  meta.maintainers = [ wolfangaukang ];

  options.defaultajAgordoj.dev = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables the Dev tools (VSCodium)
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    {
      home.packages = settings.packages.dev;
      programs.vscode = {
        enable = true;
        package = settings.vscode.package;
        extensions = settings.vscode.extensions;
        userSettings = settings.vscode.userSettings;
      };
    }
  ]);
}
