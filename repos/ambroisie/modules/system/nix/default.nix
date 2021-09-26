# Nix related settings
{ config, inputs, lib, pkgs, ... }:
let
  cfg = config.my.system.nix;
in
{
  options.my.system.nix = with lib; {
    enable = my.mkDisableOption "nix configuration";

    addToRegistry = my.mkDisableOption "add inputs and self to registry";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      nix = {
        package = pkgs.nixFlakes;

        extraOptions = ''
          experimental-features = nix-command flakes
        '';
      };
    }

    (lib.mkIf cfg.addToRegistry {
      nix.registry = {
        # Allow me to use my custom package using `nix run self#pkg`
        self.flake = inputs.self;
        # Use pinned nixpkgs when using `nix run pkgs#<whatever>`
        pkgs.flake = inputs.nixpkgs;
        # Add NUR to run some packages that are only present there
        nur.flake = inputs.nur;
      };
    })
  ]);
}
