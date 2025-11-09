# from colinsane/nur-packages
# modified to be a standard overlay

final: prev:
let
  lib = prev.lib; #pkgs.lib;
  sane-additional = with final; # (
    # lib.filesystem.packagesFromDirectoryRecursive {
      # inherit callPackage;
      # directory = ./by-name;
    # }
   { # ) //
    ### nix expressions / helpers
    # sane-data = import ../modules/data { inherit lib sane-lib; };
    # sane-lib = import ../modules/lib final';

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
in sane-overlay 

