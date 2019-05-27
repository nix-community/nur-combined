{ lib, stdenv, linuxPackages, structuredExtraConfig ? values: { }, ... } @ pkgs:

linuxPackages.extend (lib.const (ksuper: {
  kernel = with import <nixpkgs/lib/kernel.nix> { inherit lib; version = ksuper.kernel.version; };
    ksuper.kernel.override {
      kernelPatches = ksuper.kernel.kernelPatches ++ [ (import ./kernel-gcc-patch.nix pkgs) ];
      structuredExtraConfig = {
        PREEMPT = yes;
        KERNEL_XZ = no;
        MODULE_COMPRESS = no;
        MODULE_COMPRESS_XZ.freeform = null;

        # Unnecessary modules
        BTRFS_FS = no;
        BTRFS_FS_POSIX_ACL.freeform = null;
      } // (structuredExtraConfig (import <nixpkgs/lib/kernel.nix> { inherit lib; version = ksuper.kernel.version; }));
    };
  }))
