# this supports being used as an overlay or in a standalone context
# - if overlay, invoke as `(final: prev: import ./. { inherit final; pkgs = prev; })`
# - if standalone: `import ./. { inherit pkgs; }`
#
# using the correct invocation is critical if any packages mentioned here are
# additionally patched elsewhere
#
{ pkgs, final ? null }:
let
  lib = pkgs.lib;
  unpatched = pkgs;
  final' = if final != null then final else pkgs.extend (_: _: sane-overlay);
  sane-additional = with final'; (
    lib.filesystem.packagesFromDirectoryRecursive {
      inherit callPackage;
      directory = ./by-name;
    }
  ) // {
    ### nix expressions / helpers
    sane-data = import ../modules/data { inherit lib sane-lib; };
    sane-lib = import ../modules/lib final';

    ### ADDITIONAL KERNEL PACKAGES
    # build like `nix-build -A linuxPackages.rk818-charger`
    #   or `nix-build -A hosts.moby.config.boot.kernelPackages.rk818-charger`
    linuxKernel = unpatched.linuxKernel // {
      # don't update by default since most of these packages are from a different repo (i.e. nixpkgs).
      updateWithSuper = false;

      packagesFor = kernel: (unpatched.linuxKernel.packagesFor kernel).extend (kFinal: kPrev: (
        lib.filesystem.packagesFromDirectoryRecursive {
          inherit (kFinal) callPackage;
          directory = ./linux-packages;
        }
      ));
    };

    ### ADDITIONAL MPV SCRIPTS
    # build like `nix-build -A mpvScripts.sane-cast`
    mpv-unwrapped = unpatched.mpv-unwrapped.overrideAttrs (base: {
      # don't update by default since most of these packages are from a different repo (i.e. nixpkgs).
      updateWithSuper = false;

      passthru = base.passthru // {
        scripts = base.passthru.scripts.overrideScope (sFinal: sPrev: (
          lib.recurseIntoAttrs (
            lib.filesystem.packagesFromDirectoryRecursive {
              inherit (sFinal) callPackage;
              directory = ./mpv-scripts;
            }
          )
        ));
      };
    });

    ### aliases
    # nixpkgs = nixpkgs-bootstrap.master;
    # nixpkgs-staging = nixpkgs-bootstrap.staging;
    # nixpkgs-next = nixpkgs-bootstrap.staging-next;
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
      (pname: _pkg: if unpatched ? "${pname}" && !(final'.sane.recurseForDerivations or false) && unpatched."${pname}" ? version && lib.versionAtLeast unpatched."${pname}".version final'.sane."${pname}".version  then
        unpatched."${pname}"
      else
        final'.sane."${pname}"
      )
      sane-additional
    )
  ;
in sane-overlay
