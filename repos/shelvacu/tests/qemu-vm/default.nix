{
  pkgs,
  lib,
  inputs,
  vacuModules,
  ...
}:
let
  hostGatewayIP = "10.78.77.1";
  guestIP = "10.78.77.2";
  guestMac = "52:54:00:12:34:56";

  # Minimal NixOS guest that boots from a virtiofs rootfs.
  # Uses the same pkgs as the test to avoid redundant builds.
  # The inner VM runs under KVM (nested virtualization), so boot is fast.
  guestSystem =
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
          boot.kernelParams = [
            "console=ttyS0"
          ];

          networking.useNetworkd = true;
          systemd.network.enable = true;
          systemd.network.networks."10-eth" = {
            matchConfig.Type = "ether";
            networkConfig = {
              DHCP = "no";
              Address = "${guestIP}/24";
              Gateway = hostGatewayIP;
            };
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
in
{
  name = "qemu-vm";

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

    vacu.qemuVMs.test-vm = {
      rootDir = "/tmp/test-vm-root";
      mac = guestMac;
      address = guestIP;
      baseMem = 512;
      maxMem = 2048;
      cpus = 1;
      # KVM (nested virtualization) — the host node exposes /dev/kvm to the
      # inner VM, so boot is fast.
      accel = "kvm";
      autoStart = false;
    };

    # Register the guest system closure as valid in the host node's Nix DB so
    # `bootstrap-test-vm` can query its requisites and copy it into the rootfs.
    virtualisation.additionalPaths = [ guestSystem ];

    # Give the host node enough RAM to run a 512 MiB QEMU guest
    virtualisation.memorySize = 2048;
    virtualisation.cores = 2;
    # Room for the ~1.1 GiB guest closure copied into /tmp/test-vm-root.
    virtualisation.diskSize = 4096;
  };

  testScript = ''
    host.start()
    host.wait_for_unit("multi-user.target")

    # IPv4 forwarding must be enabled for routed VM networking
    host.succeed("test \"$(cat /proc/sys/net/ipv4/ip_forward)\" = 1")

    # Populate the guest rootfs from the pre-built NixOS system closure.
    host.succeed("bootstrap-test-vm ${guestSystem}", timeout=600)

    # Verify the profile symlink was created
    host.succeed("test -L /tmp/test-vm-root/nix/var/nix/profiles/system")

    # Start virtiofsd and QEMU
    host.systemctl("start vacuvm-test-vm-qemu.service")

    # preStart sets up the routed tap: gateway IP on the tap and a /32 host
    # route back to the guest.
    host.wait_until_succeeds("ip link show tap-test-vm", timeout=30)
    host.succeed("ip route get ${guestIP} | grep -q 'dev tap-test-vm'")

    # Wait for the guest to boot and come up on the routed network.
    host.wait_until_succeeds("ping -c1 -W2 ${guestIP}", timeout=120)
  '';

  skipTypeCheck = true;
  skipLint = true;
}
