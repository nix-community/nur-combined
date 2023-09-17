{ config, pkgs, lib, inputs, materusFlake, ... }:
let
  startHook = /*''


    # Debugging
      exec 19>/home/materus/startlogfile
      BASH_XTRACEFD=19
      set -x

      exec 3>&1 4>&2
      trap 'exec 2>&4 1>&3' 0 1 2 3
      exec 1>/home/materus/startlogfile.out 2>&1
    ''
    +*/
    ''
    # Make sure nothing renders on gpu to prevent "sysfs: cannot create duplicate filename" after rebinding to amdgpu
    chmod 0 /dev/dri/renderD128 
    fuser -k /dev/dri/renderD128

    # Seems to fix reset bug for 7900 XTX
    echo "0" > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/d3cold_allowed"

    systemctl stop mountWin10Share.service
    
    
    echo ''$VIRSH_GPU_VIDEO > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/driver/unbind"
    echo ''$VIRSH_GPU_AUDIO > "/sys/bus/pci/devices/''${VIRSH_GPU_AUDIO}/driver/unbind"

    sleep 1s

    echo "10" > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/resource0_resize"
    echo "8" > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/resource2_resize"


    systemctl set-property --runtime -- user.slice AllowedCPUs=12-15,28-31
    systemctl set-property --runtime -- system.slice AllowedCPUs=12-15,28-31
    systemctl set-property --runtime -- init.scope AllowedCPUs=12-15,28-31


  '';
  stopHook = ''

    # Debugging
    #  exec 19>/home/materus/stoplogfile
    #  BASH_XTRACEFD=19
    #  set -x

    #  exec 3>&1 4>&2
    #  trap 'exec 2>&4 1>&3' 0 1 2 3
    #  exec 1>/home/materus/stoplogfile.out 2>&1


        
    sleep 1s
    echo ''$VIRSH_GPU_VIDEO > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/driver/unbind"
    echo ''$VIRSH_GPU_AUDIO > "/sys/bus/pci/devices/''${VIRSH_GPU_AUDIO}/driver/unbind"

        
    

    echo "15" > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/resource0_resize"
    echo "8" > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/resource2_resize"
    echo "1" > "/sys/bus/pci/devices/''${VIRSH_GPU_VIDEO}/d3cold_allowed"


    echo ''$VIRSH_GPU_VIDEO > /sys/bus/pci/drivers/amdgpu/bind
    echo ''$VIRSH_GPU_AUDIO > /sys/bus/pci/drivers/snd_hda_intel/bind


    systemctl start mountWin10Share.service

    systemctl set-property --runtime -- user.slice AllowedCPUs=0-31
    systemctl set-property --runtime -- system.slice AllowedCPUs=0-31
    systemctl set-property --runtime -- init.scope AllowedCPUs=0-31

  

  '';
in
{








  virtualisation.libvirtd.hooks.qemu = {
    "win10" = pkgs.writeShellScript "win10.sh" ''
      VIRSH_GPU_VIDEO="0000:03:00.0"
      VIRSH_GPU_AUDIO="0000:03:00.1"
      VIRSH_USB1="0000:10:00.0"

      if [ ''$1 = "win10" ] || [ ''$1 = "win11" ]; then
        if [ ''$2 = "prepare" ] && [ ''$3 = "begin" ]; then
          ${startHook}
        fi

        if [ ''$2 = "release" ] && [ ''$3 = "end" ]; then
          ${stopHook}
        fi

      fi

    
    '';
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
