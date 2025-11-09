final: prev:
let
  lib = prev.lib;
  sane-additional = with final;
   { 
    ### KERNEL PACKAGES
    # build like `nix-build -A linuxPackages.rk818-charger`
    #   or `nix-build -A hosts.moby.config.boot.kernelPackages.rk818-charger`
    linuxKernel = prev.linuxKernel // {
      # don't update by default since most of these packages are from a different repo (i.e. nixpkgs).
      updateWithSuper = false;

      packagesFor = kernel: (prev.linuxKernel.packagesFor kernel).extend (kFinal: kPrev: (
        lib.filesystem.packagesFromDirectoryRecursive {
          inherit (kFinal) callPackage;
          directory = ../pkgs/linux-packages;
        }
      ));
    };

    ### aliases
    inherit (trivial-builders)
      copyIntoOwnPackage
      deepLinkIntoOwnPackage
      linkBinIntoOwnPackage
      linkIntoOwnPackage
      rmDbusServices
      rmDbusServicesInPlace
      runCommandLocalOverridable
    ;
  };

  sane-overlay = {
    sane = lib.recurseIntoAttrs sane-additional;
  }
    # "additional" packages only get added if their version is newer than upstream, or if they're package sets
    // (lib.mapAttrs
      (pname: _pkg: 
        final.sane."${pname}"
      )
      sane-additional
    )
  ;
in
{
  linuxKernel = prev.linuxKernel // {
    updateWithSuper = false;
    packagesFor = kernel:
      (prev.linuxKernel.packagesFor kernel).extend (_final: _prev:
        lib.filesystem.packagesFromDirectoryRecursive {
          inherit (final) callPackage;
          directory = ../pkgs/linux-packages;
        }
      );
  };
}# sane-overlay 

