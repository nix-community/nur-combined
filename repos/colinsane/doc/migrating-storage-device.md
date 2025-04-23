## migrating a host to a new drive
1. copy persistent data off of the host:
```sh
$ mkdir -p mnt old/persist
$ mount /dev/$old mnt
$ rsync -arv mnt/persist/ old/persist/
```

2. flash the new drive
```
$ nix-build -A hosts.moby.img
$ dd if=$(readlink ./result) of=/dev/$new bs=4M oflag=direct conv=sync status=progress
```

3. expand the partition and filesystem
```sh
$ cfdisk /dev/$new
# scroll to the last partition
> Resize
  leave at default (max)
> Write
  type "yes"
> Quit
$ btrfs filesystem resize max /dev/$new
```

4. copy data onto the new host
```
$ mkdir new
$ mount /dev/$new new
# if you want to use btrfs snapshots (e.g. snapper), then create the data directory as a subvolume:
$ sudo btrfs subvolume create new/persist
# restore the data
$ rsync -arv old/persist/ new/persist/
```

5. ensure/fix ownership
```
$ chmod -R a+rX new/nix
# or, let the nix daemon do it:
$ nix copy --no-check-sigs --to new $(nix-build -A hosts.moby)
```
```
6. insert the disk into the system, and boot!
