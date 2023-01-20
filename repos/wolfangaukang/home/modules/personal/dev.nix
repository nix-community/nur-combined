{ config, lib, pkgs, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  cfg = config.defaultajAgordoj.dev;
  settings = import ./settings.nix { inherit pkgs; };

in
{
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
    { home.packages = settings.packages.dev; }
    (import ../../profiles/common/vscode.nix { inherit pkgs; })
  ]);

  meta.maintainers = with maintainers; [ wolfangaukang ];
}