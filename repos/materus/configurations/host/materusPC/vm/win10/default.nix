{ config, pkgs, lib, inputs, materusFlake, ... }:
{



  environment.etc = {
    "libvirt/hooks/kvm.conf" = {
      text =
        ''
          VIRSH_GPU_VIDEO="0000:03:00.0"
          VIRSH_GPU_AUDIO="0000:03:00.1"
        '';
      mode = "0755";
    };

    "libvirt/hooks/qemu.d/win10/prepare/begin/start.sh" = {
      text = ''
        #!${pkgs.bash}/bin/bash
        source /etc/libvirt/hooks/kvm.conf

        systemctl stop mountWin10Share.service

        echo ''$VIRSH_GPU_VIDEO > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/driver/unbind"
        echo ''$VIRSH_GPU_AUDIO > "/sys/bus/pci/devices/''${VIRSH_GPU_AUDIO}/driver/unbind"

        sleep 1s

        echo "8" > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/resource0_resize"
        echo "1" > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/resource2_resize"

      '';
      mode = "0755";
    };

    "libvirt/hooks/qemu.d/win10/release/end/stop.sh" = {
      text = ''
        #!${pkgs.bash}/bin/bash
        source /etc/libvirt/hooks/kvm.conf

        

        echo ''$VIRSH_GPU_VIDEO > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/driver/unbind"
        echo ''$VIRSH_GPU_AUDIO > "/sys/bus/pci/devices/''${VIRSH_GPU_AUDIO}/driver/unbind"

        sleep 1s

        echo "15" > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/resource0_resize"
        echo "8" > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/resource2_resize"

        echo ''$VIRSH_GPU_VIDEO > /sys/bus/pci/drivers/amdgpu/bind
        echo ''$VIRSH_GPU_AUDIO > /sys/bus/pci/drivers/snd_hda_intel/bind

        systemctl start mountWin10Share.service

      '';
      mode = "0755";
    };
  };


  systemd.services.mountWin10Share = {
    wantedBy = [ "multi-user.target" ];
    path = [ config.virtualisation.libvirtd.qemu.package pkgs.util-linux pkgs.kmod pkgs.coreutils ];
    serviceConfig.Type = "oneshot";
    serviceConfig.RemainAfterExit = true;
    script = ''
      modprobe nbd max_part=16
      sleep 1
      qemu-nbd -c /dev/nbd0 /materus/data/VM/data.qcow2 --cache=unsafe --discard=unmap
      sleep 1
      mount /dev/nbd0p1 /materus/data/Windows -o uid=1000,gid=100
    '';
    preStop = ''
      umount /materus/data/Windows
      qemu-nbd -d /dev/nbd0
    '';
  };
}
