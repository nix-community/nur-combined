{ unstable-path, unstable, libidn }:

rec {
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  logitech-k380 = ./logitech-k380.nix;
  qt5 = ./qt5.nix;
  gtk = ./gtk.nix;
  jack = ./jack.nix;
  pulseaudio = ./pulseaudio.nix;
  pipewire = ./pipewire.nix;
  bambootracker = ./bambootracker.nix;
  nvidia = ./nvidia.nix;
  job = ./job.nix;
  monitor = import ./monitor.nix unstable;
  server = ./server.nix;
  steam = ./steam.nix;
  wifi = ./wifi.nix;
  rkn = import ./rkn.nix libidn;
}
