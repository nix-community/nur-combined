# ZFS and BTRFS implementation on system

### Observation

This guide goes on hand with NixOS impermanence. You will find some general instructions, but again, the idea is implementing impermanence through these filesystems.

## ZFS Setup

- Perform any previous preparation of the disk, hopefully using the encrypted setup
- Create the main ZFS pool by running `zpool create pool-name /path/to/disk`
  - If using LVM, the disk path would be on `/dev/mapper/volume-name`
- Enable autotrim (for better SSD performance) by running `zpool set autotrim=on pool-name`
- Now, create the ZFS datasets in the pool by running `zfs create -o compression=on -o mountpoint=legacy pool-name/dataset-name`
  - On NixOS, it is mandatory to use the `-o mountpoint=legacy` option for better interoperation
  - You can create pools and datasets from it. It will depend of the desired levels
  - If creating a `/var` pool, it will require the `-o acltype=posixacl` option, so users can access their own journal logs, and the `-o xattr=sa` option to handle extended attributes the ZFS way.
- If you want to enable automatic snapshots, you need to run `zfs set com.sun:auto-snapshot=true pool-name/dataset-path`.
  - If you want to enable autosnapshots in a certain period (`frequently`, `hourly`, `daily`, `weekly` or `monthly`), run `zfs set com.sun:auto-snapshot:PERIOD=true pool-name/dataset-path`. You will also need to add the option `services.zfs.autoSnapshot.PERIOD` on your `configuration.nix`
- Create the directories we want to mount on the system 
- Mount the datasets on the corresponding system by running `mount -t zfs pool-name/dataset-path /system/path`
- Run the NixOS installation as usual

### Sources
- [Basic setup that is related with Impermanence](https://grahamc.com/blog/erase-your-darlings)
- [Similar guide as above, but only focused on setting up ZFS](https://ipetkov.dev/blog/installing-nixos-and-zfs-on-my-desktop/)
- [Basic guide to snapshots](https://www.thegeeksearch.com/beginners-guide-to-zfs-snapshots/)
- [Handling automatic snapshots](https://docs.oracle.com/cd/E19120-01/open.solaris/817-2271/ghzuk/index.html)
- [Removing wrongly set attributes](https://serverfault.com/questions/1022365/remove-a-zfs-attribute-instead-of-setting-its-value-to-default)
- [xattr=sa explanation](https://teddit.net/r/zfs/comments/44dm4l/setting_xattrsa_after_the_fact/)

## BTRFS Setup

- Perform any previous preparation of the disk, hopefully using the encrypted setup.
  - This means creating a partition table, creating partitions, setting up LVM, creating physical/logical volumes, etc.
- Create BTRFS with `mkfs.btrfs /path/to/disk --label label_to_set`.
  - If using LVM, the disk path would be on `/dev/mapper/volume-name`.
  - The label part is optional, but very useful.
- Mount the drive with `mount -t btrfs /path/to/disk /mnt`
  - You can replace the disk path with label (`LABEL=labelname`)
- Create the subvolumes with `btrfs sub create /subvol/path`
  - For example, if you mounted `/mnt`, then you will use `btrfs sub create /mnt/name`
  - Currently we are using `.snapshots`, `home`, `nix` and `persist` (latter for impermanence)
- Unmount the btrfs volume 
- Mount tmpfs on `/mnt` with `mount -t tmpfs tmpfs /mnt`
- Create the directories we want to mount on the system 
- Create a variable with the mount options (`o_btrfs="defaults,ssd,compress=zstd,noatime,discard=async,space_cache=v2"`)
- Mount the btrfs subvolumes with `mount -t btrfs -o $o_btrfs,subvol=subvol_name /mnt/nix`
- Run the NixOS installation as usual

### Sources
- [An introductory video about BTRFS](https://piped.tokhmi.xyz/watch?v=RPO-fS6HQbY)
- [First script I checked regarding BTRFS on NixOS](https://github.com/shiryel/nixos-dotfiles/blob/master/_scripts/setup_disk.sh)
