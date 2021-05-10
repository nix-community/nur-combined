{ config, lib, pkgs, ...}@args:
let
  sources = import ../../nix/default.nix;
in
{
  options.nixExperimental.enable = lib.mkEnableOption "whether to set up the experimental version of nix";
  config = lib.mkIf config.nixExperimental.enable {
    nix = {
      package = pkgs.nixFlakes;
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      registry = lib.mapAttrs (k: v: { flake = v; }) 
        (args.inputs or (import sources.flake-compat { src = ../..; }).defaultNix.inputs);
    };
  };
}
