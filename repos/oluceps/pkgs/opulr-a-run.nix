{ qemu, writeShellApplication, fd_iuBrGE }:

writeShellApplication {
  name = "opulr-a-run";
  text = ''
    ${qemu}/bin/qemu-system-aarch64 \
    -cpu cortex-a57 \
    -machine virt -nographic -m 8192 -smp 22 \
    -bios ${fd_iuBrGE}/FV/QEMU_EFI.fd \
    -device virtio-net-device,netdev=usernet \
    -netdev user,id=usernet,hostfwd=tcp::12055-:22 \
    -device qemu-xhci -usb -device usb-kbd -device usb-tablet \
    -drive file=/var/lib/libvirt/images/openEuler-22.03-LTS-SP1-aarch64.qcow2,format=qcow2,if=virtio
    "$@"
  '';
}
