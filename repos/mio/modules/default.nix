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
      ];
    }
  );
  zfs-impermanence-on-shutdown = ./zfs-impermanence-on-shutdown.nix;
}
