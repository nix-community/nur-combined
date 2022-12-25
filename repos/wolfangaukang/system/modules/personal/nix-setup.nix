{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profile.nix;

in
{
  meta.maintainers = [ wolfangaukang ];

  options.profile.nix = {
    enableAutoOptimise = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables autoOptimiseStore 
      '';
    };
    enableFlakes = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables flakes 
      '';
    };
    enableUseSandbox = mkOption {
      default = false;
      type = types.bool;
      description = ''
        Enables sandbox 
      '';
    };
  };

  config = mkMerge [
    {
      nix.settings = {
        auto-optimise-store = mkIf cfg.enableAutoOptimise true;
        sandbox = mkIf cfg.enableUseSandbox true;
      };
    }
    (mkIf cfg.enableFlakes {
      nix = {
        package = pkgs.nixUnstable;
        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };
    })
  ];
}

