{
  flake.modules.nixos.lowram =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      cfg = config.minRam;
    in
    {
      options.minRam = {
        enable = lib.mkEnableOption "Aggressive memory footprint optimizations based on lowendspirit guide";

        kernelParams = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Disable memory profiling, KFENCE, THP, and unnecessary kernel threads via cmdline";
        };

        blacklistedModules = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Blacklist virtualization and hardware modules not needed on minimal VPS/VM";
        };

        zram = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Aggressive zramSwap with zstd and optimal VM tuning (swappiness=180, page-cluster=0, watermark tuning)";
        };

        ioTuning = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Optimize disk scheduler and read_ahead for virtual disks";
        };

        nixGcTuning = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Tune Boehm GC for Nix to reduce evaluation memory spikes and force immediate unmap";
        };

        socketActivatedSshd = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Use socket activation for sshd (startWhenNeeded) to free resident daemon memory";
        };

        oneshotNtp = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Replace continuous timesyncd daemon with oneshot busybox ntpd timer to save resident memory";
        };

        optimizeResolved = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Disable LLMNR and MulticastDNS in systemd-resolved to avoid multicast listening overhead";
        };

        trimClosure = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Disable unused desktop/nixos utilities, fontconfig, and documentation";
        };

        trimModulesTree = lib.mkOption {
          type = lib.types.bool;
          default = false;
          description = "Aggressively prune sound, GPU, and unneeded network drivers from kernel modules tree";
        };
      };

      config = lib.mkIf cfg.enable (
        lib.mkMerge [
          (lib.mkIf cfg.kernelParams {
            boot.kernelParams = [
              # Allocation profiling tracking tables cost ~6MB (3.9MB vmalloc, 1.9MB slab)
              "sysctl.vm.mem_profiling=never"
              # Get back 2MB KFENCE pool
              "kfence.sample_interval=0"
              # Drop kdamond thread
              "damon_stat.enabled=N"
              # Drop kauditd thread
              "audit=0"
              # Drop ksmd (1.4MB) and TPM bits (0.3MB + kthread)
              "initcall_blacklist=ksm_init,tpm_init,init_tis"
              # Reduce kthreads and startup background self-tests
              "psi=0"
              "ras=cec_disable"
              "nowatchdog"
              "nmi_watchdog=0"
              "cryptomgr.notests"
              "8250.nr_uarts=1"
              # Massive win: avoids THP inflating vm.min_free_kbytes (frees 50-100MB+ reserved memory on low-RAM hosts)
              "transparent_hugepage=never"
            ];
          })

          (lib.mkIf cfg.blacklistedModules {
            # Blacklist hardware/modules a guest VM never needs
            boot.blacklistedKernelModules = [
              "virtio_console" # holds 8MB kmalloc-4k slab when unused
              "floppy"
              "intel_agp"
              "i2c_piix4"
              "psmouse"
              "mousedev"
              "joydev"
              "serio_raw"
              "mac_hid"
              "input_leds"
              "evdev"
              "rapl"
              "intel_rapl_msr"
              "intel_rapl_common"
              "intel_cstate"
              "intel_uncore"
              "kvm_intel"
              "kvm_amd"
              "kvm"
              "cfg80211" # loaded by networkd for nl80211 even without wifi
              "ata_generic"
              "pata_acpi"
              "qemu_fw_cfg"
              "dmi_sysfs"
              "vga16fb"
              "virtio_gpu"
            ];

            # Modules requested at switch-root with no device present
            boot.extraModprobeConfig = lib.concatMapStrings (m: "install ${m} ${pkgs.coreutils}/bin/false\n") [
              "vsock"
              "vmw_vsock_virtio_transport"
              "vsock_loopback"
              "vmw_vsock_vmci_transport"
              "vmw_vmci"
              "virtiofs"
            ];
          })

          (lib.mkIf cfg.zram {
            zramSwap = {
              enable = true;
              algorithm = "zstd";
              memoryPercent = lib.mkDefault 100;
              memoryMax = lib.mkDefault 536870912; # 512MB
              priority = lib.mkDefault 100;
            };

            # Disable zswap so zram operates cleanly without conflict
            boot.zswap.enable = lib.mkDefault false;

            boot.kernel.sysctl = {
              "kernel.panic_on_oops" = lib.mkDefault 1;
              "kernel.panic" = lib.mkDefault 10;
              # Compress cold anon pages into zram rather than discarding page cache
              "vm.swappiness" = lib.mkForce 180;
              # Readahead on zram is wasted CPU and memory
              "vm.page-cluster" = lib.mkDefault 0;
              # kswapd starts earlier to avoid stalls in direct reclaim during rebuilds
              "vm.watermark_scale_factor" = lib.mkForce 125;
              "vm.watermark_boost_factor" = lib.mkDefault 0;
            };
          })

          (lib.mkIf cfg.ioTuning {
            # Set noop scheduler and lower readahead for virtual disks
            services.udev.extraRules = ''
              ACTION=="add|change", KERNEL=="vd[a-z]*|sd[a-z]*", ENV{DEVTYPE}=="disk", ATTR{queue/scheduler}="none", ATTR{queue/read_ahead_kb}="128"
            '';
          })

          (lib.mkIf cfg.nixGcTuning {
            # Tune Boehm GC used by Nix to constrain heap growth and release pages immediately
            environment.variables = {
              GC_INITIAL_HEAP_SIZE = "33554432";
              GC_FREE_SPACE_DIVISOR = "8";
              GC_FORCE_UNMAP_ON_GCOLLECT = "1";
            };
          })

          (lib.mkIf cfg.socketActivatedSshd {
            services.openssh.startWhenNeeded = true;
          })

          (lib.mkIf cfg.oneshotNtp {
            services.timesyncd.enable = false;
            systemd.services.minram-ntp = {
              description = "One-shot clock sync";
              after = [ "network-online.target" ];
              wants = [ "network-online.target" ];
              serviceConfig = {
                Type = "oneshot";
                ExecStart = "${pkgs.busybox}/bin/ntpd -n -q ${
                  lib.concatMapStringsSep " " (s: "-p ${s}") (
                    if config.networking.timeServers != [ ] then config.networking.timeServers else [ "pool.ntp.org" ]
                  )
                }";
              };
            };
            systemd.timers.minram-ntp = {
              wantedBy = [ "timers.target" ];
              timerConfig = {
                OnBootSec = "30s";
                OnCalendar = "hourly";
                Persistent = true;
              };
            };
          })

          (lib.mkIf cfg.optimizeResolved {
            services.resolved.settings.Resolve = {
              LLMNR = lib.mkForce "false";
              MulticastDNS = lib.mkForce "false";
            };
          })

          (lib.mkIf cfg.trimClosure {
            # Cut unused desktop, tools, and docs
            systemd.oomd.enable = lib.mkDefault false;
            systemd.suppressedSystemUnits = [
              "systemd-importd.service"
              "sys-kernel-config.mount"
            ];
            system.tools = {
              nixos-option.enable = lib.mkDefault false;
              nixos-build-vms.enable = lib.mkDefault false;
              nixos-install.enable = lib.mkDefault false;
              nixos-enter.enable = lib.mkDefault false;
            };
            xdg = {
              mime.enable = lib.mkDefault false;
              icons.enable = lib.mkDefault false;
              sounds.enable = lib.mkDefault false;
            };
            fonts.fontconfig.enable = lib.mkDefault false;
            boot.bcache.enable = lib.mkDefault false;
            services.lvm.enable = lib.mkDefault false;
            security.pam.services.su.forwardXAuth = lib.mkForce false;
            documentation = {
              enable = lib.mkDefault false;
              man.enable = lib.mkDefault false;
              nixos.enable = lib.mkDefault false;
            };
          })

          (lib.mkIf cfg.trimModulesTree {
            system.modulesTree =
              let
                kernel = config.boot.kernelPackages.kernel;
                moduleTreeRemove = [
                  "kernel/sound/*"
                  "kernel/drivers/accel/*"
                  "kernel/drivers/accessibility/*"
                  "kernel/drivers/atm/*"
                  "kernel/drivers/auxdisplay/*"
                  "kernel/drivers/bcma/*"
                  "kernel/drivers/bluetooth/*"
                  "kernel/drivers/bus/*"
                  "kernel/drivers/clk/*"
                  "kernel/drivers/comedi/*"
                  "kernel/drivers/counter/*"
                  "kernel/drivers/cpufreq/*"
                  "kernel/drivers/crypto/*"
                  "kernel/drivers/cxl/*"
                  "kernel/drivers/dca/*"
                  "kernel/drivers/devfreq/*"
                  "kernel/drivers/dma/*"
                  "kernel/drivers/edac/*"
                  "kernel/drivers/extcon/*"
                  "kernel/drivers/firewire/*"
                  "kernel/drivers/fpga/*"
                  "kernel/drivers/fsi/*"
                  "kernel/drivers/fwctl/*"
                  "kernel/drivers/gnss/*"
                  "kernel/drivers/gpio/*"
                  "kernel/drivers/greybus/*"
                  "kernel/drivers/hid/*"
                  "kernel/drivers/hsi/*"
                  "kernel/drivers/hv/*"
                  "kernel/drivers/hwmon/*"
                  "kernel/drivers/hwtracing/*"
                  "kernel/drivers/i2c/*"
                  "kernel/drivers/i3c/*"
                  "kernel/drivers/iio/*"
                  "kernel/drivers/infiniband/hw/*"
                  "kernel/drivers/ipack/*"
                  "kernel/drivers/leds/*"
                  "kernel/drivers/macintosh/*"
                  "kernel/drivers/mailbox/*"
                  "kernel/drivers/mcb/*"
                  "kernel/drivers/media/*"
                  "kernel/drivers/memstick/*"
                  "kernel/drivers/message/*"
                  "kernel/drivers/mfd/*"
                  "kernel/drivers/mmc/*"
                  "kernel/drivers/most/*"
                  "kernel/drivers/mtd/*"
                  "kernel/drivers/mux/*"
                  "kernel/drivers/nfc/*"
                  "kernel/drivers/ntb/*"
                  "kernel/drivers/nvdimm/*"
                  "kernel/drivers/nvmem/*"
                  "kernel/drivers/parport/*"
                  "kernel/drivers/pcmcia/*"
                  "kernel/drivers/peci/*"
                  "kernel/drivers/perf/*"
                  "kernel/drivers/phy/*"
                  "kernel/drivers/pinctrl/*"
                  "kernel/drivers/platform/*"
                  "kernel/drivers/power/*"
                  "kernel/drivers/powercap/*"
                  "kernel/drivers/rapidio/*"
                  "kernel/drivers/ras/*"
                  "kernel/drivers/regulator/*"
                  "kernel/drivers/reset/*"
                  "kernel/drivers/rpmsg/*"
                  "kernel/drivers/siox/*"
                  "kernel/drivers/slimbus/*"
                  "kernel/drivers/soc/*"
                  "kernel/drivers/soundwire/*"
                  "kernel/drivers/spi/*"
                  "kernel/drivers/spmi/*"
                  "kernel/drivers/ssb/*"
                  "kernel/drivers/staging/*"
                  "kernel/drivers/tee/*"
                  "kernel/drivers/thermal/*"
                  "kernel/drivers/thunderbolt/*"
                  "kernel/drivers/ufs/*"
                  "kernel/drivers/usb/*"
                  "kernel/drivers/w1/*"
                  "kernel/drivers/xen/*"
                  "kernel/drivers/video/fbdev/*"
                  "kernel/drivers/video/backlight/*"
                  "kernel/drivers/gpu/drm/*/*"
                  "kernel/drivers/input/joystick/*"
                  "kernel/drivers/input/touchscreen/*"
                  "kernel/drivers/input/tablet/*"
                  "kernel/drivers/input/gameport/*"
                  "kernel/drivers/input/rmi4/*"
                  "kernel/drivers/net/ethernet/*"
                  "kernel/drivers/net/wireless/*"
                  "kernel/drivers/net/wwan/*"
                  "kernel/drivers/net/usb/*"
                  "kernel/drivers/net/arcnet/*"
                  "kernel/drivers/net/fddi/*"
                  "kernel/drivers/net/hamradio/*"
                  "kernel/drivers/net/hippi/*"
                  "kernel/drivers/net/ieee802154/*"
                  "kernel/drivers/net/wan/*"
                  "kernel/drivers/net/plip/*"
                  "kernel/drivers/net/fjes/*"
                  "kernel/drivers/net/hyperv/*"
                  "kernel/drivers/net/vmxnet3/*"
                  "kernel/drivers/net/xen-netback/*"
                  "kernel/drivers/net/xen-netfront.ko*"
                  "kernel/drivers/net/thunderbolt/*"
                  "kernel/drivers/net/mhi_net.ko*"
                  "kernel/drivers/net/dsa/*"
                  "kernel/drivers/net/rionet.ko*"
                  "kernel/drivers/net/ntb_netdev.ko*"
                  "kernel/drivers/net/sungem_phy.ko*"
                  "kernel/drivers/block/floppy.ko*"
                  "kernel/drivers/block/mtip32xx/*"
                  "kernel/drivers/block/xen-blk*"
                  "kernel/drivers/scsi/*"
                  "kernel/drivers/ata/*"
                  "kernel/drivers/watchdog/*"
                  "kernel/drivers/rtc/*"
                ];
                moduleTreeKeep = [
                  "kernel/drivers/gpu/drm/virtio/*"
                  "kernel/drivers/scsi/scsi_mod.ko*"
                  "kernel/drivers/scsi/scsi_common.ko*"
                  "kernel/drivers/scsi/sd_mod.ko*"
                  "kernel/drivers/scsi/sr_mod.ko*"
                  "kernel/drivers/scsi/sg.ko*"
                  "kernel/drivers/scsi/st.ko*"
                  "kernel/drivers/scsi/ch.ko*"
                  "kernel/drivers/scsi/ses.ko*"
                  "kernel/drivers/scsi/raid_class.ko*"
                  "kernel/drivers/scsi/virtio_scsi.ko*"
                  "kernel/drivers/scsi/scsi_transport_*"
                  "kernel/drivers/scsi/iscsi_tcp.ko*"
                  "kernel/drivers/scsi/libiscsi.ko*"
                  "kernel/drivers/scsi/libiscsi_tcp.ko*"
                  "kernel/drivers/scsi/iscsi_boot_sysfs.ko*"
                  "kernel/drivers/ata/libata.ko*"
                  "kernel/drivers/ata/ata_piix.ko*"
                  "kernel/drivers/ata/ahci.ko*"
                  "kernel/drivers/ata/libahci.ko*"
                  "kernel/drivers/watchdog/watchdog.ko*"
                  "kernel/drivers/watchdog/i6300esb.ko*"
                  "kernel/drivers/watchdog/softdog.ko*"
                  "kernel/drivers/rtc/rtc-cmos.ko*"
                ];
                modulesSrc = lib.getOutput "modules" kernel;
                trimmedModules =
                  pkgs.runCommand "${kernel.name}-modules-trimmed" { nativeBuildInputs = [ pkgs.kmod ]; }
                    ''
                      set -f
                      remove="${lib.concatStringsSep " " moduleTreeRemove}"
                      keep="${lib.concatStringsSep " " moduleTreeKeep}"
                      ver=$(ls ${modulesSrc}/lib/modules)
                      src=${modulesSrc}/lib/modules/$ver
                      dst=$out/lib/modules/$ver
                      match() { local f=$1 p; for p in $2; do case $f in $p) return 0;; esac; done; return 1; }
                      declare -A want
                      while IFS= read -r line; do
                        m=''${line%%:*}
                        if match "$m" "$remove" && ! match "$m" "$keep"; then continue; fi
                        want[$m]=1
                        for d in ''${line#*:}; do want[$d]=1; done
                      done < $src/modules.dep
                      for m in "''${!want[@]}"; do mkdir -p "$dst/$(dirname "$m")"; cp "$src/$m" "$dst/$m"; done
                      cp $src/modules.builtin $src/modules.builtin.modinfo $dst/
                      while IFS= read -r o; do
                        for m in "$o" "$o.xz" "$o.zst" "$o.gz"; do [ -n "''${want[$m]:-}" ] && { echo "$o"; break; }; done
                      done < $src/modules.order > $dst/modules.order
                      depmod -b $out -a $ver
                    '';
              in
              lib.mkForce ([ trimmedModules ] ++ config.boot.extraModulePackages);
          })
        ]
      );
    };
}
