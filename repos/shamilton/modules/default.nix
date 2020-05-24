{
  # Add your NixOS modules here
  #
  nixos = {
    day-night-plasma-wallpapers = ./day-night-plasma-wallpapers-nixos.nix;
  };
  home-manager = {
    day-night-plasma-wallpapers = ./day-night-plasma-wallpapers-home-manager.nix;
  };
}

