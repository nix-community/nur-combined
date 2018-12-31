{
  flang = import ./flang-overlay;
  qemu-user = import ./qemu-user.nix;
  intel-compilers = import ./intel-compilers-overlay;

  nix-home-nfs-robin-ib-bguibertd = import ./nix-store-overlay.nix "/home_nfs_robin_ib/bguibertd/nix";
  nix-scratch-gpfs-bguibertd      = import ./nix-store-overlay.nix "/scratch_gpfs/bguibertd/nix";
}

