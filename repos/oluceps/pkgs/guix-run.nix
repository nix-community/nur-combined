{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "guix-run";
  text = ''
    ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -nic user,model=virtio-net-pci \
      -enable-kvm -m 2048 \
      -drive if=virtio,format=qcow2,file=/var/lib/virt/guix-system-vm-image-1.4.0.x86_64-linux.qcow2 \
      "$@"
  '';
}
