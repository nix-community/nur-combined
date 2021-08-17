{ unstable-path, unstable }:

rec {
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  logitech-k380 = ./logitech-k380.nix;
  qt5 = ./qt5.nix;
  gtk = ./gtk.nix;
  jack = ./jack.nix;
  pulseaudio = ./pulseaudio.nix;
  bambootracker = ./bambootracker.nix;
  nvidia = ./nvidia.nix;
  job = ./job.nix;
  # JUST UPDATE RELEASE
  ddccontrol = "${unstable-path}/nixos/modules/services/hardware/ddccontrol.nix";
  monitor = import ./monitor.nix unstable ddccontrol;
}
