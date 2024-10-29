{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "bkworm";
  text = ''
    ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -machine accel=kvm,type=q35 \
      -cpu host -smp 22 \
      -m 31G \
      -nographic \
      -device virtio-net-pci,netdev=net0 \
      -netdev user,id=net0,hostfwd=tcp::2222-:22,hostfwd=tcp::8080-:8080 \
      -drive if=virtio,format=qcow2,file=/var/lib/virt/debian-12-nocloud-amd64-daily-20230911-1500.qcow2 \
      "$@"
  '';
}
