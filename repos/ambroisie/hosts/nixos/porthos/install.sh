#!/bin/sh

SWAP_SIZE=16GiB

parted /dev/sda --script -- \
    mklabel gpt \
    mkpart primary 512MiB -$SWAP_SIZE \
    mkpart primary linux-swap -$SWAP_SIZE 100% \
    mkpart ESP fat32 1MiB 512MiB \
    set 3 esp on

parted /dev/sdb --script -- \
    mklabel gpt \
    mkpart primary 0% 100%
parted /dev/sdc --script -- \
    mklabel gpt \
    mkpart primary 0% 100%
parted /dev/sdd --script -- \
    mklabel gpt \
    mkpart primary 0% 100%

mkfs.ext4 -L media1 /dev/sda1
mkfs.ext4 -L media2 /dev/sdb1
mkfs.ext4 -L media3 /dev/sdc1
mkfs.ext4 -L media4 /dev/sdd1

pvcreate /dev/sda1
pvcreate /dev/sdb1
pvcreate /dev/sdc1
pvcreate /dev/sdd1
vgcreate lvm /dev/sda1 /dev/sdb1 /dev/sdc1 /dev/sdd1
lvcreate -l 100%FREE -n media lvm

mkfs.ext4 -L nixos /dev/mapper/lvm-media
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3

mount /dev/disk/by-label/nixos /mnt
swapon /dev/sda2
mkdir -p /mnt/boot
mount /dev/disk/by-label/boot /mnt/boot

apt install sudo
useradd -m -G sudo setupuser

cat << EOF
# Run the following commands as setup user
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
nix profile install nixpkgs#nixos-install-tools
sudo "$(which nixos-generate-config)" --root /mnt

# Change uuids to labels
vim /mnt/etc/nixos/hardware-configuration.nix

# Install system
mkdir -p /mnt/home/ambroisie/git/nix/config
cd /mnt/home/ambroisie/git/nix/config

nix-env -iA nixos.git nixos.nix nixos.git-crypt
git clone <this-repo> .
# Assuming you set up GPG key correctly
git crypt unlock

nixos-install --root /mnt --flake '.#<hostname>'
EOF

# shellcheck disable=2117
su setupuser
