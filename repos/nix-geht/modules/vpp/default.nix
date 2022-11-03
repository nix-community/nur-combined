{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.services.vpp;
  vpp-pkgs = pkgs.callPackage ../../pkgs/vpp {}; # TODO: I just wanna have this. How can I make it prettier?

  # Helpers.
  MB = 1024 * 1024;
  divRoundUp = x: n: (x + (n - 1)) / n;

  # VPP data-size and buffer-size defaults are 2048b and 2496b, respectively.
  # Thus, per 2M HugePage, we can fit 840 full pages.
  buffersPer2MHP = 2 * MB / 2496;
  loglevelType = types.enum [ "emerg" "alert" "crit" "error" "warn" "notice" "info" "debug" "disabled" ];
in
{
  options.services.vpp = {
    enable = mkEnableOption "Vector Packet Processor";
    package = mkOption {
      default = vpp-pkgs.vpp;
      defaultText = "pkgs.vpp";
      type = types.package;
      description = "vpp package to use.";
    };
    pollSleepUsec = mkOption {
      type = with types; nullOr (int);
      default = 100;
      description = ''
        Amount of Microseconds to sleep between each poll, greatly reducing CPU usage,
        at the expense of latency/throughput.
        Defaults to 100us.
      '';
    };
    bootstrap = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Optional startup commands to execute on startup to bootstrap the VPP instance.
      '';
    };
    defaultLogLevel = mkOption {
      type = loglevelType;
      default = "info";
      description = ''
        Set default logging level for logging buffer.
        Defaults to "info".
      '';
    };
    defaultSyslogLogLevel = mkOption {
      type = loglevelType;
      default = "notice";
      description = ''
        Set default logging level for syslog or stderr output.
        Defaults to "notice".
      '';
    };
    statsegSize = mkOption {
      type = types.int;
      default = 32;
      description = ''
        Size (in MiB) of the stats segment.
        Defaults to 32 MiB.
      '';
    };
    mainCore = mkOption {
      type = types.int;
      default = 1;
      description = ''
        Logical Core to run main thread on.
        Defaults to 1.
      '';
    };
    workers = mkOption {
      type = types.int;
      default = 0;
      description = ''
        Number of workers to create.
        Workers will be pinned to next free CPU core after main thread's core.
        Defaults to 0 - no workers.
      '';
    };
    mainHeapSize = mkOption {
      type = types.int;
      default = 1024;
      description = ''
        Set the main heap page size (in MiB).
        Defaults to 1024 MiB, which suffices for a Full Table.
      '';
    };
    buffersPerNuma = mkOption {
      type = types.int;
      default = 16384;
      description = ''
        Set the buffer count per NUMA Node.
        Defaults to 16384 buffers.
      '';
    };
    numberNumaNodes = mkOption {
      type = types.int;
      default = 4;
      description = ''
        Sets the number of NUMA nodes for maximum number of hugepages calculation.
        Defaults to 4 (AMD EPYC, 4 Processor systems, etc..)
      '';
    };
    uioDriver = mkOption {
      type = types.enum [ "vfio-pci" "uio_pci_generic" "igb_uio" ];
      default = "vfio-pci";
      description = ''
        UIO driver to use. Recommendations:
        Use vfio-pci when IOMMU is enabled and supported. (default)

        The latter two need IOMMU off or in passthrough mode.
        Use uio_pci_generic if you can't use vfio-pci.
        Use igb_uio when legacy interrupts aren't available, like when using VFs.

        See: https://doc.dpdk.org/guides/linux_gsg/linux_drivers.html
      '';
    };
    extraConfig = mkOption {
      type = types.lines;
      default = "";
      description = ''
        Additional startup config to configure VPP with.
        Add clauses like `dpdk { ... }` here.
      '';
    };
    netlinkBufferSize = mkOption {
      type = types.int;
      default = 64;
      description = ''
        Set the sysctl options for netlink buffer sizes (in Megabyte).
        Default (64MiB) should suffice for 1M routes.
      '';
    };
    additionalHugePages = mkOption {
      type = types.int;
      default = 0;
      description = ''
        Additional huge pages allowed to be overcommitted.
        Defaults to 0.
      '';
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ cfg.package ];
    users.groups.vpp = {};

    # Create a VPP Service.
    systemd.services.vpp = {
      wantedBy = [ "multi-user.target" ];
      before = [ "network.target" "network-online.target" ];
      after = [ "network-pre.target" "systemd-sysctl.service" ];
      description = "Vector Packet Processor Engine";
      path = [ cfg.package ];
      restartTriggers = [ config.environment.etc."vpp/startup.conf".source ]
      ++ optionals (cfg.bootstrap != 0) [ config.environment.etc."vpp/bootstrap.vpp".source ]; # Restart on any changes to our config. VPP doesn't do reloads.
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/vpp -c /etc/vpp/startup.conf";
        ExecStartPost = "${pkgs.coreutils}/bin/rm -f /dev/shm/db /dev/shm/global_vm /dev/shm/vpe-api";
      };
    };

    # Write the config files.
    environment.etc."vpp/startup.conf" = {
      enable = true;
      mode = "0644";
      text = ''
        # VPP Startup Config.
        # Generated by Nix.
        # Don't touch here.

        unix {
          nodaemon
          log /var/log/vpp/vpp.log
          cli-listen /run/vpp/cli.sock
          gid vpp
          ${optionalString (cfg.pollSleepUsec != 0) ''
          poll-sleep-usec ${toString cfg.pollSleepUsec}
          ''}
          ${optionalString (cfg.bootstrap != "") ''
          exec /etc/vpp/bootstrap.vpp
          ''}
        }

        logging {
          default-log-level ${cfg.defaultLogLevel}
          default-syslog-log-level ${cfg.defaultSyslogLogLevel}
        }

        # Enable APIs.
        api-trace { on }
        api-segment { gid vpp }
        socksvr { default }

        statseg {
          size ${toString cfg.statsegSize}M
          page-size default-hugepage
          per-node-counters off
        }

        cpu {
          main-core ${toString cfg.mainCore}
          ${optionalString (cfg.workers != 0) ''
          workers ${toString cfg.workers}
          ''}
        }
        memory {
          main-heap-size ${toString cfg.mainHeapSize}M
          main-heap-page-size default-hugepage
        }
        buffers {
          buffers-per-numa ${toString cfg.buffersPerNuma}
          # buffer = 128b header + 128b scratchpad + data-size
          default data-size 2048
          page-size default-hugepage
        }

        plugins {
          # Linux CP
          plugin linux_nl_plugin.so { enable }
          plugin linux_cp_plugin.so { enable }

          plugin arping_plugin.so { disable }
          plugin igmp_plugin.so { disable }
          plugin ping_plugin.so { disable }

          # Broken plugins.
          plugin lisp_plugin.so { disable }
        }

        linux-cp {
          lcp-sync
          lcp-auto-subint
        }

        dpdk {
          # Make device 0000:00:14.1 (enp0s20f1) become GigabitEthernet0/20/1
          # instead of GigabitEthernet0/14/1 to be more like kernel/cisco names.
          decimal-interface-names

          uio-driver ${cfg.uioDriver}
        }

        ${optionalString (cfg.extraConfig != "") ''
        # Extra Config
        ${cfg.extraConfig}
        ''}
      '';
    };

    environment.etc."vpp/bootstrap.vpp" = {
      enable = cfg.bootstrap != "";
      mode = "0644";
      text = cfg.bootstrap;
    };

    boot.kernelModules = [ cfg.uioDriver ];
    boot.extraModulePackages = optionals (cfg.uioDriver == "igb_uio") [ config.boot.kernelPackages.dpdk-kmods ];

    # The math doesn't work if the default hugepage size isn't 2M.
    boot.kernelParams = [ "default_hugepagesz=2M" ];

    boot.kernel.sysctl = let
      pagesRequired = divRoundUp (cfg.mainHeapSize + cfg.statsegSize) 2;
      bufferPages = divRoundUp (cfg.buffersPerNuma * cfg.numberNumaNodes) buffersPer2MHP;
    in {
      # Set netlink buffer size.
      "net.core.rmem_default" = mkDefault (cfg.netlinkBufferSize * MB);
      "net.core.wmem_default" = mkDefault (cfg.netlinkBufferSize * MB);
      "net.core.rmem_max" = mkDefault (cfg.netlinkBufferSize * MB);
      "net.core.wmem_max" = mkDefault (cfg.netlinkBufferSize * MB);

      # Hugepages.
      "vm.nr_hugepages" = mkDefault pagesRequired;
      "vm.nr_overcommit_hugepages" = mkDefault bufferPages;
      "vm.max_map_count" = 65536; # mkDefault (3 * pagesRequired + bufferPages);
      "vm.hugetlb_shm_group" = mkDefault 0;
      # kernel.shmmax is already set to a huge number.
    };
  };
}
