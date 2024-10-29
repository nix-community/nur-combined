{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "arch-run";
  text = ''
    ${pkgs.qemu}/bin/qemu-system-x86_64 \
      -machine accel=kvm,type=q35 \
      -cpu host,-rdtscp -smp 22 \
      -m 4G \
      -nographic \
      -device virtio-net-pci,netdev=net0 \
      -netdev user,id=net0,hostfwd=tcp::2225-:22 \
      -drive if=virtio,format=qcow2,file=/var/lib/virt/Arch-Linux-x86_64-basic-20240115.207158.qcow2 \
      "$@"
  '';
}
