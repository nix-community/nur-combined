{ config, lib, pkgs, ... }:
let
  qemuPackage = pkgs.qemu_kvm;
  qemuMachine = {
    x86_64-linux = "pc";
    aarch64-linux = "virt,gic-version=host";
  }.${pkgs.stdenv.hostPlatform.system};
  cfg = config.services.haos;
in
{
  options = {
    services.haos = {
      enable = lib.mkEnableOption "HAOS";
      cpu = lib.mkOption {
        type = lib.types.str;
        default = "host";
        description = "Passed as -cpu argument to qemu.";
      };
      smp = lib.mkOption {
        type = lib.types.str;
        default = "cores=2";
        description = "Passed as -smp argument to qemu.";
      };
      machine = lib.mkOption {
        type = lib.types.str;
        default = qemuMachine;
        description = "qemu machine";
      };
      mem = lib.mkOption {
        type = lib.types.int;
        default = 2;
        description = "memory size in gb.";
      };
      bridge = lib.mkOption {
        type = lib.types.str;
        example = "br0";
        description = "Bridge used for networking.";
      };
      mac = lib.mkOption {
        type = lib.types.str;
        description = "Mac address used for networking.";
      };
      usbPassthrough = lib.mkOption {
        type = lib.types.listOf (lib.types.submodule {
          options = {
            vendorid = lib.mkOption {
              type = lib.types.str;
              description = "A vendorid";
            };
            productid = lib.mkOption {
              type = lib.types.str;
              description = "A productid";
            };
          };
        });
        description = "List of usb ports.";
        default = [ ];
        example = [ { vendorid = "1a86"; productid = "7523"; } ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # required for using bridges in qemu
    environment = {
      etc."qemu/bridge.conf".text = "allow ${cfg.bridge}";
      etc.ethertypes.source = "${pkgs.iptables}/etc/ethertypes";
    };

    # needed for running quemu as non-root user
    security.wrappers.qemu-bridge-helper = {
      setuid = true;
      owner = "root";
      group = "root";
      source = "${qemuPackage}/libexec/qemu-bridge-helper";
    };

    systemd.services.haos = {
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [ qemu-utils socat xz ];
      script = ''
        set -euo pipefail

        disk=disk1.qcow2
        if [ ! -f $disk ]; then
          xz -dc ${pkgs.home-assistant-operating-system} > $disk
        fi

        exec ${lib.getExe qemuPackage} \
          -nographic \
          -cpu ${cfg.cpu} \
          -smp ${cfg.smp} \
          -M ${cfg.machine} \
          -m ${toString cfg.mem}G \
          -drive if=pflash,format=raw,unit=0,readonly=on,file=${pkgs.OVMF.firmware} \
          -drive if=pflash,format=raw,unit=1,readonly=on,file=${pkgs.OVMF.variables} \
          -netdev bridge,id=hn0,helper=/run/wrappers/bin/qemu-bridge-helper,br=${cfg.bridge} \
          -device virtio-net-pci,netdev=hn0,id=nic0,mac=${cfg.mac} \
          -device virtio-balloon \
          -device virtio-rng-pci \
          -object iothread,id=iothread0 \
          -device virtio-scsi-pci,iothread=iothread0,id=scsi0 \
          -device scsi-hd,drive=hd0,bus=scsi0.0,serial=disk1 \
          -drive if=none,id=hd0,file=$disk,format=qcow2,discard=unmap \
          -usb -device qemu-xhci ${lib.concatStringsSep " \\\n" (lib.map (v: "-device usb-host,vendorid=0x${v.vendorid},productid=0x${v.productid}") cfg.usbPassthrough)} \
          -chardev socket,path=qga.sock,server=on,wait=off,id=qga0 \
          -device virtio-serial \
          -device virtserialport,chardev=qga0,name=org.qemu.guest_agent.0 \
          -monitor unix:qemu.monitor,server,nowait \
          -vnc :0
      '';
      preStop = ''
        echo '{"execute": "guest-shutdown"}' | socat stdio,ignoreeof ./qga.sock
      '';
      serviceConfig = {
        # User = "qemu-libvirtd";
        TimeoutStopSec = 15 * 60;
        Restart = "on-failure";
        StateDirectory = "haos";
        WorkingDirectory="/var/lib/haos";
      };
    };
  };
}
