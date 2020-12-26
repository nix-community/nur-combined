{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  logitech-k380 = ./logitech-k380;
  qt5 = ./qt5;
  # https://github.com/NixOS/nixpkgs/pull/103531
  acpilight = import <nixos-unstable/nixos/modules/hardware/acpilight.nix>;
}

