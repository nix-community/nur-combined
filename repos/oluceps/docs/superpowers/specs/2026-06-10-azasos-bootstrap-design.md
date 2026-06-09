# Azasos Machine Bootstrap Design

**Date:** 2026-06-10
**Hostname:** azasos
**Purpose:** Bootstrap a new machine configuration based on `bootstrap.nix`.

## 1. Node Registration
Add `azasos` to `registry.toml` with the following attributes:
- `id`: 6
- `addrs`: `["2401:b60:e0fe:3e::2"]`
- `censor`: `false`
- `nat`: `false`
- `user`: `riro`
- `ssh_key`: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJDkqNdrR49Id2NjA01qx6E5dff5Bn6uqkmMnSZX9i1e`
- `mac`: `bc:24:11:21:c7:2c`
- `ygg_pubkey`: `c4da53e606530fca7cf7c1c756956258`

Update `mod/constant.nix` to include `azasos` in the `hosts` attribute set.

## 2. Storage (Disko)
Create `mod/disko/azasos.nix`.
- **Layout:** GPT
- **Partitions:**
  - `boot`: 1M (EF02)
  - `ESP`: 256M (EF00, vfat, mounted at `/boot`)
  - `solid`: Rest of disk (BTRFS)
- **BTRFS Subvolumes:**
  - `root`: mounted at `/`
  - `nix`: mounted at `/nix`
  - `var`: mounted at `/var`
  - `persist`: mounted at `/persist`

## 3. Secrets (Vaultix)
Update `mod/age.nix` to include `age/azasos` module.
- **Secrets:** `sing`, `age`.
- **Host Keys:** Standard ed25519 host key at `/var/lib/ssh/ssh_host_ed25519_key`.

## 4. Networking
Update `mod/net.nix` to include `net/azasos` module.
- **Interface:** `eno1` (matched by MAC `bc:24:11:21:c7:2c`)
- **Address:** `2401:b60:e0fe:3e::2/64`
- **Gateway:** `2401:b60:e0fe:3e::1`
- **Features:** IPv6 forwarding, MulticastDNS, IPv6 AcceptRA.

## 5. System Configuration
Create `mod/hosts/azasos.nix`.
- **Imports:** Standard system modules + `vxlan-mesh`, `yggdrasil`.
- **Boot:** Grub on `/dev/sda`, standard kernel parameters from `bootstrap.nix`.
- **State Version:** `25.11` (from `bootstrap.nix`).

## 6. Routing (BGP/Bird)
Create `mod/bird/azasos.nix`.
- **Config:** Include `babel-auth` secret, basic bird import.
