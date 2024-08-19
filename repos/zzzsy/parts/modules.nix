{
  flake = {
    hmModules = {
      #@TODO
    };
    nixosModules = {
      gnome-fix = import ../modules/nixos/gnome-fix.nix;
    };
  };
}
