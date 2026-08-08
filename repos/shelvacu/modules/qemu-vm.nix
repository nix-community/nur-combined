{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib) mkOption types mkIf;
  netCfg = config.vacu.vmNet;
  cfg = config.vacu.qemuVMs;

  vmSubmodule = types.submodule (
    { name, config, ... }: {
      options = {
        rootDir = mkOption {
          type = types.str;
          description = "Path to the guest rootfs directory on the host.";
          example = "/vms/my-vm/root";
          default = "/vms/${name}/root";
        };
        mac = mkOption {
          type = types.str;
          description = ''
            MAC address for the guest virtio-net NIC. Defaults to a unicast,
            locally-administered address derived from `address`
            (02:00:<ip-bytes-in-hex>), so it is unique per guest, stable, and
            can never land on the multicast bit. Rarely needs to be set.
          '';
          example = "52:54:00:12:34:56";
          default =
            let
              octets = lib.splitString "." config.address;
              hexPair = n: lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString (lib.toInt n)));
            in
            "02:00:${lib.concatMapStringsSep ":" hexPair octets}";
        };
        address = mkOption {
          type = types.str;
          description = ''
            Guest IPv4 address (no prefix). The host adds a /32 route to it via
            the VM's tap interface. The guest should use this address and point
            its default gateway at vacu.vmNet.gateway.
          '';
          example = "10.78.77.2";
        };
        baseMem = mkOption {
          type = types.ints.positive;
          default = 512;
          description = "Initial guest memory in MiB.";
        };
        maxMem = mkOption {
          type = types.ints.positive;
          default = config.baseMem * 4;
          description = "Maximum guest memory in MiB (for virtio-balloon/hotplug).";
        };
        dimmSlots = mkOption {
          type = types.ints.positive;
          default = 4;
          description = "Number of DIMM hotplug slots.";
        };
        cpus = mkOption {
          type = types.ints.positive;
          default = 1;
          description = "Number of vCPUs.";
        };
        accel = mkOption {
          type = types.enum [
            "kvm"
            "tcg"
          ];
          default = "kvm";
          description = "QEMU accelerator: \"kvm\" (production) or \"tcg\" (software, for testing).";
        };
        autoStart = mkOption {
          type = types.bool;
          default = true;
          description = "Whether to start the VM automatically at boot.";
        };
      };
    }
  );

  # Per-VM service definitions — evaluated lazily as values inside the config attrset.
  # Using a plain attrset for `config` (not lib.mkMerge at top-level) so the module
  # system can determine contributed option keys without forcing these thunks, avoiding
  # a fixed-point cycle through config.vacu.qemuVMs.
  vmServices = lib.pipe cfg [
    (lib.mapAttrsToList (
      vmName: vmCfg:
      let
        tapName = "v-${vmName}";
        runtimeDir = "vacuvm-${vmName}";
        virtiofsdSocket = "/run/${runtimeDir}/virtiofsd.sock";
        # Host-only (RuntimeDirectory) dir the guest kernel/initrd are copied
        # into each boot; the guest has no access to it.
        bootRuntimeDir = "vacuvm-${vmName}-boot";
        bootDir = "/run/${bootRuntimeDir}";
        slice = "vacuvm-${vmName}.slice";
        qemuUnit = "vacuvm-${vmName}-qemu.service";
        virtiofsdUnit = "vacuvm-${vmName}-virtiofsd.service";
        useKvm = vmCfg.accel == "kvm";
        cpu = if useKvm then "host" else "max";
        netdevExtra = lib.optionalString useKvm ",vhost=on";
      in
      [
        {
          name = "vacuvm-${vmName}-virtiofsd";
          value = {
            description = "virtiofsd rootfs for ${vmName}";
            before = [ qemuUnit ];
            requiredBy = [ qemuUnit ];
            unitConfig.AssertPathExists = vmCfg.rootDir;
            serviceConfig = {
              ExecStart = "${pkgs.virtiofsd}/bin/virtiofsd --socket-path ${virtiofsdSocket} --shared-dir ${vmCfg.rootDir} --cache always";
              # virtiofsd has no sd_notify support, so Type=notify would hang
              # forever. Type=simple + the socket wait in the qemu unit below.
              Type = "simple";
              RuntimeDirectory = runtimeDir;
              Restart = "on-failure";
              Slice = slice;
            };
          };
        }
        {
          name = "vacuvm-${vmName}-qemu";
          value = {
            description = "QEMU VM ${vmName}";
            wantedBy = lib.optional vmCfg.autoStart "multi-user.target";
            requires = [ virtiofsdUnit ];
            after = [
              virtiofsdUnit
              "network.target"
            ];

            # Routed networking (no bridge): the tap gets the host-side gateway
            # address and a /32 host route back to the guest. The guest uses
            # vacu.vmNet.gateway as its default gateway.
            postStart = ''
              # ${pkgs.iproute2}/bin/ip link del ${tapName} 2>/dev/null || true
              # ${pkgs.iproute2}/bin/ip tuntap add ${tapName} mode tap
              while ! [[ -d /proc/sys/net/ipv4/conf/${tapName} ]]; do
                sleep 1
              done
              ${pkgs.iproute2}/bin/ip addr add ${netCfg.gateway}/32 dev ${tapName}
              ${pkgs.iproute2}/bin/ip link set ${tapName} up
              ${pkgs.iproute2}/bin/ip route replace ${vmCfg.address}/32 dev ${tapName}
              # Strict reverse-path filtering = anti-spoofing: the kernel drops
              # any packet arriving on this tap whose source IP does not route
              # back out this same tap (i.e. anything other than ${vmCfg.address}).
              # VMs can still reach each other and the LAN freely — just not with
              # a forged source IP. (Effective iff net.ipv4.conf.all.rp_filter is
              # 0 or 1; kernel default is 0.)
              echo 1 > /proc/sys/net/ipv4/conf/${tapName}/rp_filter
            '';

            # Deleting the tap also drops its address and the /32 route.
            postStop = ''
              ${pkgs.iproute2}/bin/ip link del ${tapName} 2>/dev/null || true
            '';

            script = ''
              set -euo pipefail

              # Lift the guest's *current* kernel/initrd/cmdline out of its
              # (guest-writable) rootfs into the host-only boot dir. confine-copy
              # resolves each path with rootDir as "/" (RESOLVE_IN_ROOT), so a
              # malicious guest cannot point kernel/initrd at a host file; the
              # copy runs every boot, so in-guest kernel updates are picked up.
              profile=/nix/var/nix/profiles/system
              ${pkgs.confine-copy}/bin/confine-copy "${vmCfg.rootDir}" "$profile/kernel"        "${bootDir}/kernel"
              ${pkgs.confine-copy}/bin/confine-copy "${vmCfg.rootDir}" "$profile/initrd"        "${bootDir}/initrd"
              ${pkgs.confine-copy}/bin/confine-copy "${vmCfg.rootDir}" "$profile/kernel-params" "${bootDir}/kernel-params"
              params=$(cat "${bootDir}/kernel-params")

              # virtiofsd (Type=simple) creates its listening socket
              # asynchronously; wait for it before starting QEMU.
              for _ in $(seq 1 100); do
                [ -S "${virtiofsdSocket}" ] && break
                sleep 0.1
              done

              # We boot the kernel directly (no boot loader), so init= — which a
              # boot loader would normally supply — must be on the command line;
              # the guest's stage-1 refuses to boot without it. The profile path
              # tracks in-guest system updates.
              exec ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 \
                -machine q35,accel=${vmCfg.accel} \
                -cpu ${cpu} \
                -smp ${toString vmCfg.cpus} \
                -m ${toString vmCfg.baseMem}M,slots=${toString vmCfg.dimmSlots},maxmem=${toString vmCfg.maxMem}M \
                -object memory-backend-memfd,id=mem0,size=${toString vmCfg.baseMem}M,share=on \
                -numa node,memdev=mem0 \
                -device virtio-balloon-pci \
                -chardev socket,id=virtiofs0,path=${virtiofsdSocket} \
                -device vhost-user-fs-pci,chardev=virtiofs0,tag=rootfs \
                -netdev tap,id=net0,ifname=${tapName},script=no,downscript=no${netdevExtra} \
                -device virtio-net-pci,netdev=net0,mac=${vmCfg.mac} \
                -kernel "${bootDir}/kernel" \
                -initrd "${bootDir}/initrd" \
                -append "init=/nix/var/nix/profiles/system/init root=rootfs rootfstype=virtiofs rw $params" \
                -nographic \
                -no-reboot
            '';

            unitConfig.AssertPathExists = [ "${vmCfg.rootDir}/nix/var/nix/profiles/system" ];

            serviceConfig = {
              Type = "simple";
              Restart = "on-failure";
              RestartSec = "5s";
              KillMode = "mixed";
              KillSignal = "SIGTERM";
              TimeoutStopSec = "30s";
              Slice = slice;
              # Host-only dir for the copied kernel/initrd; wiped on stop.
              RuntimeDirectory = bootRuntimeDir;
            };
          };
        }
      ]
    ))
    lib.concatLists
    lib.listToAttrs
  ];

  # One slice per VM (grouping its qemu + virtiofsd units), all nested under a
  # shared vacuvm.slice so limits can be applied to all VMs at once.
  vmSlices = {
    vacuvm.description = "All vacu QEMU VMs";
  }
  // lib.mapAttrs' (
    vmName: _vmCfg: lib.nameValuePair "vacuvm-${vmName}" { description = "vacu QEMU VM ${vmName}"; }
  ) cfg;

  vmPackages = lib.mapAttrsToList (
    vmName: vmCfg:
    pkgs.writeShellScriptBin "bootstrap-${vmName}" ''
      set -euo pipefail
      toplevel="''${1:-}"
      if [[ -z "$toplevel" ]]; then
        echo "Usage: bootstrap-${vmName} /nix/store/...-nixos-system-${vmName}" >&2
        exit 1
      fi

      echo "Creating directory structure in ${vmCfg.rootDir}..."
      mkdir -p "${vmCfg.rootDir}/nix/store"
      mkdir -p "${vmCfg.rootDir}/nix/var/nix/profiles"
      mkdir -p "${vmCfg.rootDir}/nix/var/nix/gcroots"

      echo "Copying closure (this may take a while)..."
      # Capture into a variable first so a failed query aborts (set -e does not
      # fire on failures inside a `for ... in $(...)` command substitution).
      requisites=$(${pkgs.nix}/bin/nix-store --query --requisites "$toplevel")
      for path in $requisites; do
        dest_path="${vmCfg.rootDir}$path"
        if [[ ! -e "$dest_path" ]]; then
          cp -a "$path" "$dest_path"
        fi
      done

      # Relative symlink (../../../store/<x>): three `..` climb
      # profiles -> nix -> var -> nix's parent, then into store. Must be relative
      # (not absolute) so it resolves within the rootfs both post-switch-root and
      # in the initrd, where the rootfs is mounted at /sysroot — an absolute
      # /nix/store/<x> would wrongly resolve against the initrd's own root.
      # confine-copy reads it host-side via RESOLVE_IN_ROOT (retrying the EAGAIN
      # that the `..` traversal can trigger).
      store_suffix="''${toplevel#/nix/store/}"
      ln -sfT "../../../store/$store_suffix" "${vmCfg.rootDir}/nix/var/nix/profiles/system"

      echo ""
      echo "Done. Start with: systemctl start vacuvm-${vmName}-qemu"
    ''
  ) cfg;
in
{
  options.vacu.vmNet = {
    enable = lib.mkEnableOption "routed networking for QEMU VMs";
    gateway = mkOption {
      type = types.str;
      default = "10.78.77.1";
      description = ''
        Host-side gateway IPv4 (no prefix). Assigned as a /32 to each VM's tap
        interface; guests use it as their default gateway.
      '';
    };
  };

  options.vacu.qemuVMs = mkOption {
    type = types.attrsOf vmSubmodule;
    default = { };
    description = "QEMU VMs to host on this machine, keyed by VM name.";
  };

  # Use a plain attrset here (not lib.mkMerge at top-level).
  # This lets the module system see which options we contribute to
  # without forcing any values, avoiding a fixed-point cycle.
  config = {
    # Routed networking needs IPv4 forwarding between the taps (and out to the
    # LAN). The upstream router carries a static route for the VM subnet to this
    # host; per-guest /32 routes are added by each VM's qemu service.
    boot.kernel.sysctl."net.ipv4.ip_forward" = mkIf netCfg.enable (lib.mkDefault 1);

    systemd.slices = vmSlices;

    systemd.services = vmServices;

    environment.systemPackages = vmPackages;

    # A guest NIC MAC must be unicast (I/G bit clear) and should be
    # locally-administered (U/L bit set) since these are made-up addresses.
    # The low bit of the first octet is the multicast bit — a value like
    # 11:cc:.. silently breaks host->guest ARP. The derived default always
    # satisfies this; the assertion only guards hand-set overrides.
    assertions = lib.mapAttrsToList (
      vmName: vmCfg:
      let
        firstOctet = lib.fromHexString (builtins.head (lib.splitString ":" vmCfg.mac));
      in
      {
        assertion = lib.bitAnd firstOctet 1 == 0 && lib.bitAnd firstOctet 2 == 2;
        message = "vacu.qemuVMs.${vmName}.mac (${vmCfg.mac}) must be a unicast, locally-administered address: the first octet must have the multicast bit (0x01) clear and the locally-administered bit (0x02) set (i.e. end in 2, 6, A, or E).";
      }
    ) cfg;
  };
}
