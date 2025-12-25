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
        howdy
        zfs-impermanence-on-shutdown
      ];
    }
  );
  howdy = ./howdypr.nix;
  zfs-impermanence-on-shutdown = ./zfs-impermanence-on-shutdown.nix;
}
