{
  # NixOS modules
  cachyos = import ./cachyos-kernel.nix { };
  vintagestory = ./vintagestory.nix;
}
