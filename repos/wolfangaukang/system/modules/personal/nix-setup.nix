{ config
, lib
, ...
}:

with lib;
let
  cfg = config.profile.nix;

in
{

  options.profile.nix = {
    enableAutoOptimise = mkEnableOption "Enables autoOptimiseStore";
    enableFlakes = mkEnableOption "Enables flakes";
    enableUseSandbox = mkEnableOption "Enables sandbox";
  };

  config = mkMerge [
    {
      nix.settings = {
        auto-optimise-store = cfg.enableAutoOptimise;
        sandbox = cfg.enableUseSandbox;
      };
    }
    (mkIf cfg.enableFlakes {
      nix.extraOptions = ''
        experimental-features = nix-command flakes
        keep-outputs = true
        keep-derivations = true
      '';
    })
  ];
}

