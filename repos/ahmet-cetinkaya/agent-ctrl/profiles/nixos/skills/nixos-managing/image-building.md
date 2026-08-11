# NixOS Image Building

## Contents
- ISO images
- Disk images (VM-ready, cloud)
- QEMU VM for local testing
- Custom installer ISO
- Choosing the right format

---

## Choosing the Right Image Format

| Goal | Format | Method |
|---|---|---|
| Install on bare metal | ISO | `system.build.isoImage` |
| Test config locally | QEMU VM | `nixos-rebuild build-vm` |
| Deploy to cloud (AWS, GCP) | VMDK/QCOW2/raw | `nixos-generate` or `build-image` |
| Pre-installed disk image | raw/qcow2 | `system.build.diskoImages` |
| Minimal network installer | netboot | `system.build.netbootRamdisk` |

---

## ISO Image

### Quick build

```bash
# From flake (recommended)
nix build .#nixosConfigurations.myiso.config.system.build.isoImage

# Result at ./result/iso/*.iso
ls -lh result/iso/
```

### Minimal ISO configuration

```nix
# hosts/myiso/configuration.nix
{ pkgs, modulesPath, lib, ... }:
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
  ];

  # Use latest kernel for better hardware support
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # SSH access during installation
  services.openssh.enable = true;
  users.users.root = {
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAA..." ];
    initialPassword = "nixos";   # fallback for console access
  };

  # Extra tools in installer
  environment.systemPackages = with pkgs; [
    git vim parted gptfdisk
  ];

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";
  time.timeZone = "UTC";

  system.stateVersion = "26.05";
}
```

### Graphical installer ISO

```nix
imports = [
  "${modulesPath}/installer/cd-dvd/installation-cd-graphical-gnome.nix"
];
```

### In flake.nix

```nix
outputs = { self, nixpkgs, ... }: {
  nixosConfigurations.myiso = nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [ ./hosts/myiso/configuration.nix ];
  };

  # Expose ISO as a package output for convenience
  packages.x86_64-linux.myiso =
    self.nixosConfigurations.myiso.config.system.build.isoImage;
};
```

Build with: `nix build .#myiso`

---

## QEMU VM for Local Testing

The fastest way to test a NixOS configuration without hardware.

```bash
# Build VM from flake
nixos-rebuild build-vm --flake .#myhostname

# Run it
./result/bin/run-myhostname-vm

# With more RAM and shared folder
QEMU_OPTS="-m 2048" nixos-rebuild build-vm --flake .#myhostname
```

VM runs with:
- Default user: same as your NixOS config, password `nixos`
- Shared host folder: `/tmp/shared` on host → `/tmp/xchg` in VM
- Network: SLIRP (host NAT, no inbound connections by default)

**Useful VM options in config:**

```nix
# Only apply these when running as VM
virtualisation.vmVariant = {
  virtualisation.memorySize = 2048;
  virtualisation.cores = 2;
  virtualisation.forwardPorts = [
    { from = "host"; host.port = 2222; guest.port = 22; }
  ];
};
```

---

## Disk Images (VM / Cloud Deploy)

### Using disko + nixos-anywhere

Best for creating pre-installed disk images for deployment.

### Using system.build.diskoImages (disko)

```nix
# In flake.nix packages:
packages.x86_64-linux.disk-image =
  self.nixosConfigurations.myhost.config.system.build.diskoImages;
```

```bash
nix build .#disk-image
# Produces ./result/*.img or *.qcow2
```

### Using nixos-generators (community, archived but functional)

```bash
nix run github:nix-community/nixos-generators -- \
  --format qcow2 \
  --configuration ./configuration.nix

# Available formats:
# iso, qcow2, vmware, amazon, do (DigitalOcean), gce, azure, raw, install-iso
```

With flake:
```nix
inputs.nixos-generators = {
  url = "github:nix-community/nixos-generators";
  inputs.nixpkgs.follows = "nixpkgs";
};

# In outputs:
packages.x86_64-linux.qcow2 =
  nixos-generators.nixosGenerate {
    system = "x86_64-linux";
    format = "qcow2";
    modules = [ ./configuration.nix ];
  };
```

### New nixos-rebuild build-image (NixOS 25.05+)

```bash
nixos-rebuild build-image \
  --image-variant iso \
  --flake .#myhostname

# Variants: iso, sd-card, qcow2, vmware
```

---

## Cross-Architecture Builds (aarch64 on x86_64)

```bash
# Enable binfmt on build machine
boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

# Then build normally
nix build .#nixosConfigurations.myarm-host.config.system.build.isoImage \
  --system aarch64-linux
```

Or use remote builder on native aarch64 machine:
```bash
nix build .#... --builders "ssh://aarch64-builder aarch64-linux"
```

---

## Caching Built Images

Built images are regular Nix derivations — push to binary cache to share:

```bash
nix copy --to s3://my-cache ./result
# or
cachix push my-cache ./result
```
