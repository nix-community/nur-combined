{
  # Add your NixOS modules here
  #
  # my-module = ./my-module;
  default = ./all;
  linux-enable-ir-emitter = ./linux-enable-ir-emitter;
  howdy = ./howdy;
  zfs-impermanence-on-shutdown = import ./zfs-impermanence-on-shutdown.nix;
}
