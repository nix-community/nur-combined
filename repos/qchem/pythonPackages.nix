subset: cfg: selfPkgs: superPkgs: self: super:

let
  callPackage = lib.callPackageWith (
    selfPkgs.pkgs //  # nixpkgs
    selfPkgs //       # overlay
    self //           # python
    overlay );

  lib = selfPkgs.pkgs.lib;

  overlay = {

    pychemps2 = callPackage ./pkgs/apps/chemps2/PyChemMPS2.nix { };

  } // lib.optionalAttrs super.isPy3k {
    pyqdng = callPackage ./pkgs/apps/pyQDng { };

    gpaw = callPackage ./pkgs/apps/gpaw { };

    gau2grid = callPackage ./pkgs/apps/gau2grid { };
    gau2grid-1_3_1 = callPackage ./pkgs/apps/gau2grid { version = "1.3.1"; sha256 = "0zkfil7cxjip79wqvhljk1ifjq0cwxzx6wlxgp63b6wbagma0i12"; };
    gau2grid-2_0_4 = callPackage ./pkgs/apps/gau2grid { version = "2.0.4"; sha256 = "0qypq8iax0n6yfi4223zya468v24b60nr0x43ypmsafj0104zqa6"; };

    meep = callPackage ./pkgs/apps/meep { };

    openmm = callPackage ./pkgs/apps/openmm {
      cudatoolkit = if cfg.useCuda then superPkgs.cudaPackages.cudatoolkit_11 else null;
    };

    pylibefp = callPackage ./pkgs/lib/pylibefp { };

    psi4 = callPackage ./pkgs/apps/psi4 { };

    pysisyphus = callPackage ./pkgs/apps/pysisyphus {
      orca = selfPkgs.orca;
      turbomole = selfPkgs.turbomole;
      cfour = selfPkgs.cfour;
      gaussian = selfPkgs.gaussian;
      molpro = selfPkgs.molpro;
    };

    rmsd = callPackage ./pkgs/lib/rmsd { };

    xtb-python = callPackage ./pkgs/lib/xtb-python { };
  } // lib.optionalAttrs super.isPy27 {
    pyquante = callPackage ./pkgs/apps/pyquante { };
  };

in {
  "${subset}" = overlay; # subset for release
} // overlay             # Make sure non-python packages have access
