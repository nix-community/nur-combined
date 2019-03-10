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

        # Not using Nvidia cards, so don't compile the (expensive) modules.
        FB_NVIDIA_I2C = no;
        DRM_NOUVEAU = no;
      } // (structuredExtraConfig (import <nixpkgs/lib/kernel.nix> { inherit lib; version = ksuper.kernel.version; }));
    };
  }))
