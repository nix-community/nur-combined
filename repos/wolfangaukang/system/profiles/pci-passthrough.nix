{
  inputs,
  ...
}:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
  ];

  virtualisation.qemu.options = [
    "-vga virtio"
    "-device virtio-gpu-pci"
  ];

}
