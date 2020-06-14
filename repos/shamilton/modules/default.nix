{
  # Add your NixOS modules here
  #
  modules = {
    day-night-plasma-wallpapers = ./day-night-plasma-wallpapers-nixos.nix;
  };
  hmModules = {
    day-night-plasma-wallpapers = ./day-night-plasma-wallpapers-home-manager.nix;
    myvim = ./myvim.nix;
    redshift-auto = ./redshift-auto.nix;
    sync-database = ./sync-database.nix;
  };
}

