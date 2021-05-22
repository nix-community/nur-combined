# Nix related settings
{ inputs, pkgs, ... }:

{
  nix = {
    package = pkgs.nixFlakes;
    registry = {
      # Allow me to use my custom package using `nix run self#pkg`
      self.flake = inputs.self;
      # Use pinned nixpkgs when using `nix run pkgs#<whatever>`
      pkgs.flake = inputs.nixpkgs;
      # Add NUR to run some packages that are only present there
      nur.flake = inputs.nur;
    };
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
