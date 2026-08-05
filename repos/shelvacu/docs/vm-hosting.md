# VM Hosting on Prophecy

## Design decisions

- **Rootfs**: writable virtiofs share backed by a btrfs subvolume on prophecy.
  The entire guest root (including `/nix/store`) lives at `/vms/<name>/root` on the host.
  Guest can run `nixos-rebuild switch` freely; the host restarts the QEMU service to
  pick up kernel updates.
- **Kernel**: passed directly via QEMU `-kernel`/`-initrd` flags, read from the guest's
  own `/nix/var/nix/profiles/system` inside the virtiofs share. No bootloader in the guest.
- **Memory**: fixed base + `virtio-balloon` for reclaiming + `maxmem`/DIMM slots defined
  for future `virtio-mem` hotplug. No KSM.
- **Networking**: dedicated bridge `vmbr0` (10.78.77.1/24) on prophecy; guests get
  static IPs in that subnet. Prophecy routes (no NAT) — the upstream router carries
  a static route for 10.78.77.0/24 via prophecy's LAN IP. Each VM's TAP is created
  in the QEMU service's `preStart` and torn down in `postStop`.
- **Persistence**: the btrfs subvolume `/vms/<name>/root` is outside prophecy's
  impermanence setup (separate subvolume, not under `/persistent`).

## Files changed

| File | What |
|------|------|
| `hosts/vacu-agent-vm/hardware.nix` | Replace VirtualBox guest with virtiofs root; no bootloader |
| `hosts/vacu-agent-vm/default.nix` | Static IP 10.78.77.2, drop networkmanager |
| `hosts/prophecy/agent-vm.nix` | New: virtiofsd + QEMU systemd services, vmbr0 bridge, fw rules, bootstrap script |
| `hosts/prophecy/btrfs.nix` | Mount btrfs subvol `vms` at `/vms` |
| `common/hosts.nix` | Update agent `primaryIp` to 10.78.77.2 |
| `common/staticNames.nix` | Add 10.78.77.2 → agent/agent-vm/vacu-agent-vm |

## Manual steps on prophecy (one-time)

### 1. Create the btrfs subvolume

```bash
# The rw mount gives access to the raw btrfs top level
mount /btr-root-in-here/rw
btrfs subvolume create /btr-root-in-here/rw/vms
umount /btr-root-in-here/rw
```

### 2. nixos-rebuild prophecy (picks up btrfs.nix change, agent-vm.nix, networking)

```bash
nixos-rebuild switch --flake .#prophecy
```

This mounts `/vms`, creates the bridge, and installs the QEMU/virtiofsd units
(but doesn't start them yet since the rootfs isn't populated).

### 3. Bootstrap the guest rootfs

```bash
# Build the guest system
toplevel=$(nix build .#nixosConfigurations.vacu-agent-vm.config.system.build.toplevel \
  --no-link --print-out-paths)

# Populate the rootfs
bootstrap-vacu-agent-vm "$toplevel"
```

The `bootstrap-vacu-agent-vm` script (installed on prophecy by agent-vm.nix):
- Creates `/vms/vacu-agent-vm/root/nix/store/` and copies the full closure
- Creates a relative symlink at `/nix/var/nix/profiles/system` inside the rootfs

### 4. Start the VM

```bash
systemctl start qemu-vacu-agent-vm
# follow logs:
journalctl -fu qemu-vacu-agent-vm
```

### 5. Configure the upstream router

Add a static route: `10.78.77.0/24 via <prophecy LAN IP (10.78.79.22)>`.

## Adding future VMs

1. Create a NixOS config under `hosts/<name>/`
2. Add a btrfs subvolume: `btrfs subvolume create /btr-root-in-here/rw/vms/<name>`
3. Add a service file `hosts/prophecy/<name>.nix` (same pattern as `agent-vm.nix`)
4. Pick an IP in 10.78.77.0/24; update `common/hosts.nix` and `common/staticNames.nix`
5. Bootstrap and start

## Memory hotplug (when needed)

To increase a running VM's memory without a restart, add a `virtio-mem` device via QMP:

```bash
# Connect to QEMU monitor
# (add -monitor unix:/run/qemu-vacu-agent-vm/monitor.sock,server,nowait to QEMU flags first)
echo '{"execute":"object-add","arguments":{"qom-type":"memory-backend-memfd","id":"hotmem0","size":4294967296,"share":true}}' | \
  nc -U /run/qemu-vacu-agent-vm/monitor.sock
echo '{"execute":"device_add","arguments":{"driver":"virtio-mem-pci","id":"vm0","memdev":"hotmem0"}}' | \
  nc -U /run/qemu-vacu-agent-vm/monitor.sock
```

The `maxmem` and DIMM slots are already configured in the QEMU command, so hotplug
up to 16384MB total is available without restarting the VM.
