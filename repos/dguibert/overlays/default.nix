{
  default = import ../overlay.nix;
  local = self: super: if (builtins.pathExists ./local.nix) then (import (./local.nix)) self super else {};

  aocc = import ./aocc-overlay;
  flang = import ./flang-overlay;
  qemu-user = import ./qemu-user.nix;
  intel-compilers = import ./intel-compilers-overlay;
  pgi = import ./pgi-overlay;

  nix-home-nfs-bguibertd          = import ./nix-store-overlay.nix "/home_nfs/bguibertd/nix";
  nix-home-nfs-robin-ib-bguibertd = import ./nix-store-overlay.nix "/home_nfs_robin_ib/bguibertd/nix";
  nix-scratch-gpfs-bguibertd      = import ./nix-store-overlay.nix "/scratch_gpfs/bguibertd/nix";
  nix-ccc-guibertd                = import ./nix-store-overlay.nix "/ccc/home/cont003/bull/guibertd/nix";
}

