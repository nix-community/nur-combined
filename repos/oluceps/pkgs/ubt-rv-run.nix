{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "ubt-rv-run";
  text = ''    
      ${pkgs.qemu}/bin/qemu-system-riscv64 \
        -machine virt -nographic -m 4096 -smp 22 \
        -bios ${pkgs.pkgsCross.riscv64.opensbi}/share/opensbi/lp64/generic/firmware/fw_jump.elf \
        -kernel ${pkgs.pkgsCross.riscv64.ubootQemuRiscv64Smode}/u-boot.bin \
        -device virtio-net-device,netdev=usernet \
        -netdev user,id=usernet,hostfwd=tcp::12056-:22 \
        -device qemu-xhci -usb -device usb-kbd -device usb-tablet \
        -drive file=/var/lib/libvirt/images/ubuntu-22.10-preinstalled-server-riscv64+unmatched.img,format=raw,if=virtio
        "$@"
  '';
}
