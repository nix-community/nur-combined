{ config, pkgs, ... }:

{
#  virtualisation.vmVariant = {
#    virtualisation = {
#      memorySize =  2048; # Use 2048MiB memory.
#      cores = 3;
#    };
#  };

#  virtualisation.qemu.options = [
#
#      # Better display option
#      "-vga virtio"
#      "-display gtk,zoom-to-fit=false"
#      # Enable copy/paste
#      # https://www.kraxel.org/blog/2021/05/qemu-cut-paste/
#      "-chardev qemu-vdagent,id=ch1,name=vdagent,clipboard=on"
#      "-device virtio-serial-pci"
#      "-device virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0"
#  ];

  users.users.nixosvmtest.isNormalUser = true ;
  users.users.nixosvmtest.initialPassword = "test";
  users.users.nixosvmtest.group = "nixosvmtest";
  users.groups.nixosvmtest = {};

}

