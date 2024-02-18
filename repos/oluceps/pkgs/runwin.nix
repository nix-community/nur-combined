{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "runwin";
  text = ''
    ${pkgs.qemu.override { smbdSupport = true; hostCpuOnly = true; }}/bin/qemu-system-x86_64 \
      -nodefaults \
      -machine q35 -accel kvm -cpu host,hv_relaxed,hv_spinlocks=0x1fff,hv_vapic,hv_time \
      -smp sockets=1,cores=6 -m 8G \
      -vga qxl \
      -device virtio-serial-pci \
      -spice port=5900,disable-ticketing=on \
      -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 \
      -chardev spicevmc,id=spicechannel0,name=vdagent \
      -nic user,model=virtio-net-pci,smb="$HOME/Downloads" \
      -drive if=virtio,file=/var/lib/libvirt/images/win10.qcow2,aio=io_uring \
      "$@"
  '';
}
# -display gtk \
