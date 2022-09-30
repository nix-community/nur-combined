# Nix related settings
{ config, inputs, lib, options, pkgs, ... }:
let
  cfg = config.my.system.nix;
in
{
  options.my.system.nix = with lib; {
    enable = my.mkDisableOption "nix configuration";

    addToRegistry = my.mkDisableOption "add inputs and self to registry";

    addToNixPath = my.mkDisableOption "add inputs and self to nix path";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      nix = {
        package = pkgs.nix;

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
        # Add NUR to run some packages that are only present there
        nur.flake = inputs.nur;
      };
    })

    (lib.mkIf cfg.addToNixPath {
      nix.nixPath = options.nix.nixPath.default ++ [
        "self=${inputs.self}"
        "pkgs=${inputs.nixpkgs}"
        "nur=${inputs.nur}"
      ];
    })
  ]);
}
