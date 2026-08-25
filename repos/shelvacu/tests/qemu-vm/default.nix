{
  pkgs,
  lib,
  inputs,
  vacuModules,
  ...
}:
let
  hostGatewayIP = "10.78.77.1";
  guestIPs = {
    test-vm = "10.78.77.2";
    test-vm2 = "10.78.77.3";
  };
  # Each guest pings the other one, so guest<->guest traffic is exercised in
  # both directions.
  peerOf = vmName: guestIPs.${if vmName == "test-vm" then "test-vm2" else "test-vm"};

  # The two guests deliberately number themselves differently, so one test run
  # covers both of the things that make VM-to-VM traffic work over the routed
  # (non-bridged, point-to-point-per-tap) host setup:
  #
  #   /32 — what in-tree guests do (modules/vacuvmGuest.nix). Nothing is on-link,
  #         so even a sibling in the VM subnet goes out the default route and the
  #         host forwards it.
  #   /24 — what an externally-managed guest naturally does, and what every guest
  #         used to do. It believes its siblings are on-link and ARPs for them
  #         directly; only the host's proxy ARP on the tap (modules/qemu-vm.nix)
  #         makes that resolve.
  prefixLenOf = vmName: if vmName == "test-vm" then "32" else "24";

  # Marker the peer-check service creates in the guest's rootfs once the peer
  # answers. The rootfs is the virtiofs share, so the host can see it directly
  # under <rootDir> without needing a login shell in the guest.
  peerMarker = "/var/lib/peer-reachable";

  # Minimal NixOS guest that boots from a virtiofs rootfs.
  # Uses the same pkgs as the test to avoid redundant builds.
  # The inner VM runs under KVM (nested virtualization), so boot is fast.
  mkGuestSystem =
    vmName:
    (inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ({ modulesPath, ... }: {
          imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

          boot.initrd.kernelModules = [ "virtiofs" ];
          boot.initrd.availableKernelModules = [ "virtio_pci" ];
          boot.kernelModules = [ ];
          boot.extraModulePackages = [ ];
          boot.loader.grub.enable = false;

          fileSystems."/" = {
            device = "rootfs";
            fsType = "virtiofs";
          };

          hardware.enableAllFirmware = false;
          hardware.enableRedistributableFirmware = false;
          boot.kernelParams = [ "console=ttyS0" ];

          networking.useNetworkd = true;
          systemd.network.enable = true;
          # See prefixLenOf above for why the two guests differ. The explicit
          # on-link route to the gateway is what modules/vacuvmGuest.nix does and
          # is required for the /32 guest (which has nothing on-link at all); it
          # is harmless for the /24 one.
          systemd.network.networks."10-eth" = {
            matchConfig.Type = "ether";
            networkConfig = {
              DHCP = "no";
              Address = "${guestIPs.${vmName}}/${prefixLenOf vmName}";
            };
            routes = [
              {
                Destination = "${hostGatewayIP}/32";
                Scope = "link";
              }
              {
                Gateway = hostGatewayIP;
                GatewayOnLink = true;
              }
            ];
          };

          # Ping the sibling VM until it answers, then drop a marker file the
          # test can read from the host side of the virtiofs share.
          systemd.services.peer-check = {
            wantedBy = [ "multi-user.target" ];
            after = [ "network-online.target" ];
            wants = [ "network-online.target" ];
            serviceConfig = {
              Type = "oneshot";
              RemainAfterExit = true;
            };
            script = ''
              rm -f ${peerMarker}
              until ${pkgs.iputils}/bin/ping -c1 -W2 ${peerOf vmName}; do
                sleep 1
              done
              mkdir -p "$(dirname ${peerMarker})"
              echo ok > ${peerMarker}
              # virtiofsd caches aggressively; make sure the host sees it.
              ${pkgs.coreutils}/bin/sync
            '';
          };

          users.users.root.initialPassword = "";
          system.stateVersion = "26.05";

          # Keep the guest closure small
          documentation.enable = false;
          environment.defaultPackages = lib.mkForce [ ];

          # Share pkgs with the test to avoid redundant builds
          nixpkgs.pkgs = pkgs;
        })
      ];
    }).config.system.build.toplevel;

  guestSystems = lib.mapAttrs (vmName: _: mkGuestSystem vmName) guestIPs;
in
{
  name = "qemu-vm";

  # Two ~1.1 GiB rootfs bootstraps plus two nested-KVM guest boots do not fit in
  # the 3600s default.
  globalTimeout = 10800;

  nodes.host = { ... }: {
    imports = [ vacuModules.qemu-vm ];

    networking.useNetworkd = true;
    systemd.network.enable = true;
    # Default DHCP for the test framework's virtual ethernet interface
    systemd.network.networks."10-default-dhcp" = {
      matchConfig.Name = "eth*";
      networkConfig.DHCP = "yes";
    };

    vacu.vmNet = {
      enable = true;
      gateway = hostGatewayIP;
    };

    # Two VMs, so the test covers guest<->guest traffic (which the host has to
    # forward between the two taps) and not just host<->guest.
    vacu.qemuVMs = lib.mapAttrs (vmName: address: {
      rootDir = "/tmp/${vmName}-root";
      inherit address;
      baseMem = 512;
      maxMem = 2048;
      cpus = 1;
      # KVM (nested virtualization) — the host node exposes /dev/kvm to the
      # inner VM. Still slow when the builder is itself a VM, but far better
      # than tcg.
      accel = "kvm";
      autoStart = false;
    }) guestIPs;

    # Register the guest system closures as valid in the host node's Nix DB so
    # `vacuvm bootstrap <vm>` can query their requisites and copy them into the
    # rootfs.
    virtualisation.additionalPaths = lib.attrValues guestSystems;

    # Enough RAM for the host node plus two 512 MiB QEMU guests
    virtualisation.memorySize = 3072;
    # The guests are nested KVM inside this node, which is itself a VM, so they
    # are slow and CPU-bound — give them more than one core each to share.
    virtualisation.cores = 4;
    # Room for the ~1.1 GiB guest closure copied into each of the two rootfs
    # dirs (separate directory trees, so it is not deduplicated).
    virtualisation.diskSize = 8192;
  };

  testScript = ''
    vms = {
      ${lib.concatStringsSep "\n      " (
        lib.mapAttrsToList (
          vmName: address: ''"${vmName}": ("${address}", "${guestSystems.${vmName}}"),''
        ) guestIPs
      )}
    }

    host.start()
    host.wait_for_unit("multi-user.target")

    # IPv4 forwarding must be enabled for routed VM networking
    host.succeed("test \"$(cat /proc/sys/net/ipv4/ip_forward)\" = 1")

    for name, (address, toplevel) in vms.items():
        # Populate the guest rootfs from the pre-built NixOS system closure.
        host.succeed(f"vacuvm bootstrap {name} {toplevel}", timeout=1800)
        # Verify the profile symlink was created
        host.succeed(f"test -L /tmp/{name}-root/nix/var/nix/profiles/system")

    for name in vms:
        host.systemctl(f"start vacuvm-{name}-qemu.service")

    for name, (address, _) in vms.items():
        # postStart sets up the routed tap: gateway IP on the tap and a /32 host
        # route back to the guest.
        host.wait_until_succeeds(f"ip link show v-{name}", timeout=60)
        host.succeed(f"ip route get {address} | grep -q 'dev v-{name}'")

        # The interactive console socket (hvc0) is created host-side by QEMU on start.
        host.wait_until_succeeds(f"test -S /run/vacuvm-{name}-boot/console.sock", timeout=60)

        # Wait for the guest to boot and come up on the routed network. Nested
        # KVM under an already-virtualised builder is slow — a guest can spend
        # several minutes just getting to initrd — so be generous here.
        host.wait_until_succeeds(f"ping -c1 -W2 {address}", timeout=900)

    # Proxy ARP must be on for the /24 guest to resolve its sibling at all.
    for name in vms:
        host.succeed(f"test \"$(cat /proc/sys/net/ipv4/conf/v-{name}/proxy_arp)\" = 1")

    # Guest-to-guest. Each tap is a separate point-to-point link, so this only
    # works if the host forwards between the taps *and* each guest can resolve
    # the peer — via the default route (the /32 guest) or via the host's proxy
    # ARP (the /24 guest). Each guest's peer-check service writes the marker into
    # its own rootfs once the other answers, so both directions are covered.
    for name in vms:
        host.wait_until_succeeds(f"test -e /tmp/{name}-root${peerMarker}", timeout=600)
  '';

  skipTypeCheck = true;
  skipLint = true;
}
