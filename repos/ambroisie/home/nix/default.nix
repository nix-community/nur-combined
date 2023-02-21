# Nix related settings
{ config, inputs, lib, options, pkgs, ... }:
let
  cfg = config.my.home.nix;
in
{
  options.my.home.nix = with lib; {
    enable = my.mkDisableOption "nix configuration";

    addToRegistry = my.mkDisableOption "add inputs and self to registry";

    overrideNixpkgs = my.mkDisableOption "point nixpkgs to pinned system version";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      nix = {
        package = lib.mkDefault pkgs.nix;

        settings = {
          experimental-features = [ "nix-command" "flakes" ];
        };
      };
    }

    (lib.mkIf cfg.addToRegistry {
      nix.registry = {
        # Allow me to use my custom package using `nix run self#pkg`
        self.flake = inputs.self;
        # Use pinned nixpkgs when using `nix run pkgs#<whatever>`
        pkgs.flake = inputs.nixpkgs;
        # ... And also with `nix run nixpkgs#<whatever>`
        nixpkgs.flake = lib.mkIf cfg.overrideNixpkgs inputs.nixpkgs;
        # Add NUR to run some packages that are only present there
        nur.flake = inputs.nur;
      };
    })
  ]);
}
