# Provisioning

NixOS installation:

```bash
# Physical partitions
sudo parted /dev/disk/by-id/example -- mklabel gpt
sudo parted /dev/disk/by-id/example -- mkpart pv-enc 512MiB 100%
sudo parted /dev/disk/by-id/example -- mkpart ESP fat32 1MiB 512MiB
sudo parted /dev/disk/by-id/example -- set 2 esp on

# Encryption
sudo cryptsetup luksFormat /dev/disk/by-partlabel/pv-enc
sudo cryptsetup luksOpen /dev/disk/by-partlabel/pv-enc pv

# Logical volumes
sudo pvcreate /dev/mapper/pv
sudo vgcreate vg /dev/mapper/pv
sudo lvcreate --name swap --size 4G vg
sudo lvcreate --name root --extents '100%FREE' vg

# Filesystems
sudo mkfs.fat -F 32 -n boot /dev/disk/by-partlabel/ESP
sudo mkswap --label swap /dev/vg/swap
sudo mkfs.btrfs --label root /dev/vg/root

# Manual mounts
sudo swapon /dev/disk/by-label/swap
sudo mount -t btrfs -o compress=zstd,noatime /dev/disk/by-label/root /mnt
sudo mkdir /mnt/boot
sudo mount /dev/disk/by-label/boot /mnt/boot

# NixOS configuration
sudo nixos-generate-config --root /mnt

# NixOS installation
sudo nixos-install --no-root-passwd
```

Channels:

```bash
# System
sudo nix-channel --add "https://nixos.org/channels/nixos-$RELEASE" 'nixos'
sudo nix-channel --add 'https://github.com/NixOS/nixos-hardware/archive/master.tar.gz' 'nixos-hardware'
sudo nix-channel --add 'https://github.com/xddxdd/nix-math/archive/master.tar.gz' 'nix-math'

# User
nix-channel --add "https://github.com/nix-community/home-manager/archive/release-$RELEASE.tar.gz" 'home-manager'
nix-channel --add 'https://nixos.org/channels/nixos-unstable' 'unstable'
nix-channel --add 'https://nixos.org/channels/nixos-unstable-small' 'unstable-small'
nix-channel --add 'https://github.com/nix-community/nix-vscode-extensions/archive/master.tar.gz' 'community-vscode-extensions'
```

Configuration structure:

```bash
git clone 'git@codeberg.org/AndrewKvalheim/configuration.git' "$HOME/src/configuration"
ln -rs "$HOME/src/configuration/hosts/$HOST/system.nix" '/etc/nixos/configuration.nix'
ln -rs "$HOME/src/configuration/hosts/$HOST/user.nix" "$HOME/.config/home-manager/home.nix"
ln -rs "$HOME/src/configuration/hosts/$HOST/packages.local.nix" "$HOME/.config/nixpkgs/overlays/packages.local.nix"
ln -rs "$HOME/src/configuration/packages.nix" "$HOME/.config/nixpkgs/overlays/packages.nix"
```

Hardware key enrollment:

```bash
sudo systemd-cryptenroll --fido2-device='auto' '/dev/disk/by-partlabel/pv-enc' # Keychain
sudo systemd-cryptenroll --fido2-device='auto' '/dev/disk/by-partlabel/pv-enc' # Backup

pamu2fcfg | sudo tee '/etc/u2f-mappings' >/dev/null # Keychain
pamu2fcfg -n | sudo tee --append '/etc/u2f-mappings' >/dev/null # Backup
```

GnuPG initialization:

```bash
gpg --import 'library/assets/andrew.asc'
gpg --card-status
```

Host-specific secrets:

```bash
# /etc/secrets
sudo mkdir '/etc/secrets'
sudo chmod o= '/etc/secrets'

# Wireguard
gopass show --password "wireguard/$HOST" | sudo tee '/etc/secrets/wg0.key' >/dev/null
sudo chmod o= '/etc/secrets/wg0.key'
```
