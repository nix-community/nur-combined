{ unstable }:

{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  logitech-k380 = ./logitech-k380;
  qt5 = ./qt5;
  gtk = ./gtk;
  jack = ./jack;
  pulseaudio = ./pulseaudio;
  bambootracker = ./bambootracker;
  nvidia = ./nvidia;
  path = [
    # https://github.com/NixOS/nixpkgs/pull/103531
    "${unstable}/nixos/modules/hardware/acpilight.nix"
  ];
}
