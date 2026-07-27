rec {
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  default = (
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      imports = [
        zfs-impermanence-on-shutdown
        darling
        wireguird
        razer-laptop-control
      ];
    }
  );
  zfs-impermanence-on-shutdown = ./zfs-impermanence-on-shutdown.nix;
  darling = ./darling.nix;
  wireguird = ./wireguird.nix;
  razer-laptop-control = ./razer-laptop-control.nix;
}
