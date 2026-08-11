---
name: luks
description: LUKS full-disk encryption on NixOS — disko setup, keyslot management, unattended unlock (TPM2, FIDO2, keyfile), and remote unlock in initrd via classic SSH or Tailscale.
---

# LUKS on NixOS

Covers: initial encrypted install, keyslot management, unattended unlock options, and the more interesting case — remotely unlocking a headless box over the network from initrd.

## 1. Basic encrypted install with disko

Single encrypted partition holding a btrfs filesystem with subvolumes:

```nix
{ disko.devices.disk.main = {
  device = "/dev/nvme0n1";
  type = "disk";
  content.type = "gpt";
  content.partitions = {
    ESP = {
      size = "512M"; type = "EF00";
      content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; };
    };
    LUKS = {
      size = "100%";
      content = {
        type = "luks";
        name = "cryptroot";               # → /dev/mapper/cryptroot
        settings = {
          allowDiscards = true;           # TRIM through LUKS (SSDs)
          bypassWorkqueues = true;        # Lower latency, small security trade-off
        };
        # Passphrase prompted interactively during `disko --mode disko`.
        # For scripted installs: passwordFile = "/tmp/luks-password";
        content = {
          type = "btrfs";
          extraArgs = [ "-f" ];
          subvolumes = {
            "@root"    = { mountpoint = "/";        mountOptions = [ "compress=zstd" "noatime" ]; };
            "@nix"     = { mountpoint = "/nix";     mountOptions = [ "compress=zstd" "noatime" ]; };
            "@persist" = { mountpoint = "/persist"; mountOptions = [ "compress=zstd" "noatime" ]; };
          };
        };
      };
    };
  };
}; }
```

Apply: `nix run github:nix-community/disko -- --mode disko --flake .#host`

Generated NixOS config includes `boot.initrd.luks.devices.cryptroot.device = "/dev/disk/by-uuid/...";` automatically via the disko module.

## 2. Keyslot management (post-install)

LUKS2 supports up to 32 keyslots. Use them — don't rely on a single passphrase.

```bash
cryptsetup luksDump /dev/nvme0n1p2             # Inspect current slots
cryptsetup luksAddKey /dev/nvme0n1p2           # Add a second passphrase
cryptsetup luksAddKey /dev/nvme0n1p2 /root/rescue.key   # Add a keyfile
cryptsetup luksRemoveKey /dev/nvme0n1p2        # Remove a slot (prompts for its key)
cryptsetup luksKillSlot /dev/nvme0n1p2 2       # Remove by slot number (no prompt — dangerous)
```

**Good hygiene:**
- Primary passphrase (memorised).
- Recovery passphrase stored offline (paper / password manager).
- One keyslot per automated method (TPM, keyfile, FIDO2) — easy to revoke individually.

## 3. Unattended unlock options

| Method | Unlocks without user present? | Survives motherboard swap? | Threat model |
|---|---|---|---|
| Passphrase at console | ❌ | ✅ | Strongest — attacker needs to coerce you |
| Keyfile on unencrypted partition | ✅ | ✅ | Useless encryption — anyone with the disk has the key |
| Keyfile on USB stick | ✅ (if stick present) | ✅ | Decent if stick stays separate from machine |
| **TPM2 sealing** | ✅ | ❌ (TPM bound to mobo) | Protects against disk-only theft; defeated by evil maid unless PCRs bound properly |
| **FIDO2 / YubiKey** | ✅ (with token tap) | ✅ | Requires physical token each boot |
| **Remote unlock** (this doc §4–5) | ✅ (from another machine) | ✅ | Network + SSH key required |

### TPM2 (systemd-cryptenroll)

```bash
systemd-cryptenroll /dev/nvme0n1p2 --tpm2-device=auto --tpm2-pcrs=0+7
```
Then on NixOS:
```nix
boot.initrd.systemd.enable = true;   # required — classic initrd can't talk to TPM2 cleanly
boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = [ "tpm2-device=auto" ];
```

PCR 7 binds to Secure Boot state; PCR 0 to firmware. Any firmware or Secure Boot change invalidates the sealing — re-enroll after BIOS updates.

### FIDO2

```bash
systemd-cryptenroll /dev/nvme0n1p2 --fido2-device=auto
```
```nix
boot.initrd.luks.devices.cryptroot.crypttabExtraOpts = [ "fido2-device=auto" ];
```

### Keyfile on separate partition

```nix
boot.initrd.luks.devices.cryptroot = {
  keyFile = "/dev/disk/by-label/KEYUSB";  # USB stick inserted at boot
  # Or fallback to passphrase if keyfile not found:
  fallbackToPassword = true;
};
```

## 4. Remote unlock — classic (dropbear / OpenSSH in initrd)

**Use when:** headless server on a trusted LAN or VPN, reboots happen and you need to SSH in from another machine to type the passphrase.

Minimal setup with scripted initrd (older but well-documented):
```nix
boot.initrd.network.enable = true;
boot.initrd.network.ssh = {
  enable = true;
  port = 2222;
  # Host keys for the initrd SSH — MUST be separate from the main system's host keys
  # (initrd runs before /etc is available). Generate once:
  #   ssh-keygen -t ed25519 -f /persist/boot/initrd_ssh_host_ed25519_key -N ""
  hostKeys = [ "/persist/boot/initrd_ssh_host_ed25519_key" ];
  authorizedKeys = [ "ssh-ed25519 AAAA...your pubkey" ];
};

# Kernel modules for the NIC — without these, no network in initrd.
# Check with: lspci -k | grep -A2 Ethernet    (look at "Kernel driver in use:")
boot.initrd.availableKernelModules = [ "r8169" "e1000e" "igb" "igc" ];

# IP config during initrd
boot.kernelParams = [ "ip=dhcp" ];
# …or static:
# boot.kernelParams = [ "ip=192.168.1.10::192.168.1.1:255.255.255.0::eth0:none" ];
```

Unlock from your laptop:
```bash
ssh -p 2222 root@server-ip
# You land in a tiny shell. Then:
cryptsetup-askpass
# …or on some setups:
systemd-tty-ask-password-agent
```

After the passphrase is accepted, boot continues and your SSH session to port 2222 dies (initrd hands off to the real system).

### Systemd-in-initrd variant (preferred on current NixOS)

```nix
boot.initrd.systemd.enable = true;
boot.initrd.systemd.network = {
  enable = true;
  wait-online.enable = false;
  networks."10-wired" = {
    matchConfig.Name = "enp*";
    networkConfig.DHCP = "yes";
  };
};

boot.initrd.network.ssh = {
  enable = true;
  port = 2222;
  hostKeys = [ "/persist/boot/initrd_ssh_host_ed25519_key" ];
  authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
};
```

With `boot.initrd.systemd.enable = true`, a `systemd-ask-password` agent runs automatically and the LUKS prompt is delivered to any connected console — including your SSH session on port 2222. No manual `cryptsetup-askpass` needed.

## 5. Remote unlock over Tailscale (VPN-in-initrd)

**Use when:** the server is reachable only via a VPN (e.g. home lab behind CGNAT, cloud VM without a public fixed IP for SSH, or you want zero-public-port exposure).

Key idea: run `tailscaled` inside initrd, bring up the tailnet, expose SSH on port 2222 on the tailnet IP, unlock via the systemd password agent. The main disk is still encrypted, so `tailscaled`'s state must live somewhere accessible before LUKS unlock — that means **a separate, unencrypted partition for the initrd tailscale state**.

### Security trade-off — be honest about it

The unencrypted partition holds: Tailscale node key, an SSH host key used only in initrd, and (optionally) a short-lived auth key. An attacker with physical disk access *can* impersonate the node on your tailnet. Mitigations:
- Use a reusable auth key with ACL tag restricting what the node can access.
- Rotate the initrd node key periodically.
- Rely on tailnet ACLs + device approval — stolen disk → unauthorize the node.

If that trade-off is unacceptable, use YubiKey / TPM2 sealing / physical console instead.

### Disko: carve out the unencrypted state partition

```nix
partitions = {
  ESP = { size = "512M"; type = "EF00"; content = { type = "filesystem"; format = "vfat"; mountpoint = "/boot"; }; };

  # Tiny unencrypted partition — holds initrd tailscale state only
  TAILSCALE_STATE = {
    size = "64M";
    content = {
      type = "filesystem";
      format = "ext4";
      mountpoint = "/var/lib/tailscale-initrd";
    };
  };

  LUKS = { size = "100%"; content = { type = "luks"; /* … as above … */ }; };
};
```

### NixOS module

```nix
{ config, lib, pkgs, ... }:

{
  boot.initrd.systemd.enable = true;

  # Drivers for NIC + anything needed to mount the state partition
  boot.initrd.availableKernelModules = [ "tun" "r8169" "ext4" ];

  # Networking in initrd
  boot.initrd.systemd.network = {
    enable = true;
    wait-online.enable = false;
    networks."10-wired" = {
      matchConfig.Name = "en*";
      networkConfig.DHCP = "yes";
    };
  };

  # Mount the unencrypted state partition early
  boot.initrd.systemd.mounts = [{
    what = "/dev/disk/by-partlabel/disk-main-TAILSCALE_STATE";
    where = "/var/lib/tailscale-initrd";
    type = "ext4";
    options = "defaults,nofail";
    before = [ "tailscaled-initrd.service" ];
    unitConfig = {
      DefaultDependencies = false;
      TimeoutStartSec = "10s";
    };
  }];

  # Binaries tailscaled needs inside initrd
  boot.initrd.systemd.storePaths = [
    "${pkgs.tailscale}/bin/tailscaled"
    "${pkgs.tailscale}/bin/tailscale"
    "${pkgs.iptables}/bin/iptables"
    "${pkgs.iproute2}/bin/ip"
  ];

  boot.initrd.systemd.services.tailscaled-initrd = {
    description = "Tailscale daemon (initrd)";
    wants = [ "network.target" ];
    after = [ "network.target" "var-lib-tailscale\\x2dinitrd.mount" ];
    requires = [ "var-lib-tailscale\\x2dinitrd.mount" ];
    wantedBy = [ "initrd.target" ];
    before = [ "initrd-switch-root.target" ];
    conflicts = [ "initrd-switch-root.target" ];   # stop cleanly before handoff
    unitConfig = {
      DefaultDependencies = false;
      FailureAction = "none";    # never block boot if tailscale fails
      TimeoutStartSec = "15s";
    };
    serviceConfig = {
      ExecStart = "${pkgs.tailscale}/bin/tailscaled \
        --state=/var/lib/tailscale-initrd/tailscaled.state \
        --socket=/run/tailscale/tailscaled.sock \
        --tun=userspace-networking \
        --port=41641";
      Type = "notify";
      RuntimeDirectory = "tailscale";
    };
  };

  boot.initrd.systemd.services.tailscale-up-initrd = {
    description = "Bring Tailscale up (initrd)";
    after = [ "tailscaled-initrd.service" ];
    requires = [ "tailscaled-initrd.service" ];
    wantedBy = [ "initrd.target" ];
    before = [ "initrd-switch-root.target" ];
    conflicts = [ "initrd-switch-root.target" ];
    unitConfig = {
      DefaultDependencies = false;
      FailureAction = "none";
      TimeoutStartSec = "30s";
    };
    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 3";
      ExecStart = "${pkgs.tailscale}/bin/tailscale up --timeout=20s";
      Type = "oneshot";
      RemainAfterExit = true;
    };
  };

  # SSH inside initrd — reachable on tailnet IP and LAN IP both
  boot.initrd.network.ssh = {
    enable = true;
    port = 2222;
    hostKeys = [ "/var/lib/tailscale-initrd/ssh_host_ed25519_key" ];
    authorizedKeys = config.users.users.root.openssh.authorizedKeys.keys;
  };
}
```

### Install-time seeding

Before first boot, drop a pre-authorised `tailscaled.state` (or auth key) and an initrd SSH host key on the unencrypted partition:

```bash
# From installer, after disko has formatted the partition:
ssh-keygen -t ed25519 -f /mnt/var/lib/tailscale-initrd/ssh_host_ed25519_key -N ""
# Option A: copy a tailscaled.state from an already-authorised node
cp tailscaled.state /mnt/var/lib/tailscale-initrd/
# Option B: drop an auth key for tailscale up to consume on first boot
echo "tskey-auth-XXXXXXXX" > /mnt/var/lib/tailscale-initrd/auth-key
```

(Option A avoids needing to authorise the initrd node manually on first boot. Option B is simpler to automate but exposes a short-lived key.)

### Unlocking from another machine

After the server reboots, wait 10–20 s for Tailscale to come up inside initrd, then:
```bash
ssh -p 2222 root@server.tailnet-name.ts.net
# Systemd password agent presents the LUKS prompt on the tty:
# (if not automatic)
systemd-tty-ask-password-agent
```
Type the passphrase → initrd finishes → real system boots → your session closes.

## 6. Debugging when it doesn't work

| Symptom | Likely cause |
|---|---|
| No SSH on port 2222 after reboot | Missing NIC kernel module in `boot.initrd.availableKernelModules`; check `dmesg` on the initrd shell console |
| SSH connects but no password prompt | Using scripted initrd without `cryptsetup-askpass`; switch to `boot.initrd.systemd.enable = true` or run the command manually |
| Tailscale never comes up in initrd | `tailscaled.state` not seeded and no auth key provided; attach a monitor or boot a rescue ISO to inspect `/var/lib/tailscale-initrd/` |
| `tailscaled` crashes on `tun` open | `tun` not in `boot.initrd.availableKernelModules` — userspace networking (`--tun=userspace-networking`) avoids this |
| Host-key-changed warning on each reboot between initrd and main system | You're SSH-ing to the same port with different host keys; use distinct ports (2222 initrd, 22 main) or accept it's expected and `HostKeyAlias` in `~/.ssh/config` |
| LUKS unlock hangs after typing passphrase | TPM2 / FIDO2 keyslot enrolled but device mismatch — dump slots with `cryptsetup luksDump` and confirm |

## 7. When *not* to use remote unlock

- Single-user laptop — passphrase at the keyboard is fine and stronger.
- Cloud VM where the provider can snapshot RAM — remote unlock doesn't help; full-disk encryption offers limited protection in that threat model anyway.
- Systems requiring tamper-evident boot (PCR-bound TPM sealing is the right tool, not remote unlock).
