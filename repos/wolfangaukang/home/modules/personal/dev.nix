{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib) maintainers types mkIf mkMerge mkOption;
  cfg = config.defaultajAgordoj.dev;

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
    { home.packages = cfg.extraPkgs; }
    (import "${inputs.self}/home/profiles/programs/vscode.nix" { inherit pkgs; })
  ]);

  meta.maintainers = with maintainers; [ wolfangaukang ];
}
