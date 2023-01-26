{ config, lib, pkgs, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  cfg = config.defaultajAgordoj.dev;
  defaultPkgs = with pkgs; [ shellcheck ];

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
    extraPkgs = mkOption {
      default = [ ];
      type = types.listOf types.package;
      description = ''
        List of extra packages to install
      '';
    };
  };

  config = mkIf cfg.enable (mkMerge [
    { home.packages = defaultPkgs ++ cfg.extraPkgs; }
    (import ../../profiles/common/vscode.nix { inherit pkgs; })
  ]);

  meta.maintainers = with maintainers; [ wolfangaukang ];
}