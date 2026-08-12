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
        local-ai
        toshy
        # toshy-hm is a Home Manager module (home.file / systemd.user).
        # Import modules.toshy-hm from Home Manager, not from NixOS.
      ];
    }
  );
  zfs-impermanence-on-shutdown = ./zfs-impermanence-on-shutdown.nix;
  darling = ./darling.nix;
  wireguird = ./wireguird.nix;
  razer-laptop-control = ./razer-laptop-control.nix;
  local-ai = ../by-name/lo/local-ai/module.nix;
  toshy = ../by-name/to/toshy/nixos-module.nix;
  toshy-hm = ../by-name/to/toshy/hm-module.nix;
}
