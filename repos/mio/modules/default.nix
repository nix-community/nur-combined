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
        miodroid
        droidloom
        local-ai
        toshy
        cutefish
      ];
    }
  );
  zfs-impermanence-on-shutdown = ./zfs-impermanence-on-shutdown.nix;
  darling = ./darling.nix;
  wireguird = ./wireguird.nix;
  razer-laptop-control = ./razer-laptop-control.nix;
  miodroid = ./miodroid.nix;
  droidloom = ../by-name/dr/droidloom/nixos-module.nix;
  local-ai = ../by-name/lo/local-ai/module.nix;
  toshy = ../by-name/to/toshy/nixos-module.nix;
  cutefish = ./cutefish.nix;
}
