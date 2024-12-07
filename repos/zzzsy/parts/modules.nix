{
  flake = {
    hmModules = {
      #@TODO
    };
    nixosModules = {
      gnome-fix = import ../modules/nixos/gnome-fix.nix;
      thinkbook14p-fix = import ../modules/nixos/thinkbook14p-fix.nix;
    };
  };
}
