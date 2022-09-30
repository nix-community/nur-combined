#!/bin/sh

SWAP_SIZE=16GiB

parted /dev/sda --script -- \
    mklabel msdos \
    mkpart primary 512MiB -$SWAP_SIZE \
    mkpart primary linux-swap -$SWAP_SIZE 100% \
    mkpart ESP fat32 1MiB 512MiB \
    set 3 esp on

parted /dev/sdb --script -- \
    mklabel gpt \
    mkpart primary 0MiB 100%

mkfs.ext4 -L media1 /dev/sda1
mkfs.ext4 -L media2 /dev/sdb1

pvcreate /dev/sda1
pvcreate /dev/sdb1
vgcreate lvm /dev/sda1 /dev/sdb1
lvcreate -l 100%FREE -n media lvm

mkfs.ext4 -L nixos /dev/mapper/lvm-media
mkswap -L swap /dev/sda2
mkfs.fat -F 32 -n boot /dev/sda3

mount /dev/disk/by-label/nixos /mnt
swapon /dev/sda2

apt install sudo
useradd -m -G sudo setupuser
su setupuser

cat << EOF
# Run the following commands as setup user
curl -L https://nixos.org/nix/install | sh
. $HOME/.nix-profile/etc/profile.d/nix.sh
nix-channel --add https://nixos.org/channels/nixos-20.09 nixpkgs
sudo `which nixos-generate-config` --root /mnt

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
