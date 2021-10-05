/*
Example of a pinned project shell. 'fetchGit' is used to reproducibly fetch the original
nixpkgs-unstable package set and the NixOS-QChem overlay. Both are therefore exactly fixed
at a non-moving commit, thus ensuring reproducability of the packages.
'mkShell' is used to define an environemt, where a set of project-associated packages is projected
into the user's environemt. Additional packages can be added to this environemt, should they become
necessary later, without modifying any other package pin.
*/

let
  # Reproducible, pinned import of the NixOS-QChem overlay function.
  qchemOvl = import (builtins.fetchGit {
    url = "https://github.com/markuskowa/NixOS-QChem.git";
    name = "NixOS-QChem_08.09.2021";
    rev = "018f5a2dcd3491f852ad1b47419e164927789ba3";
    ref = "master";
  });

  # Reproducible, pinned import of a snapshot of nixpkgs-unstable.
  # The NixOS-QChem overlay is applied to modify
  # the original nixpkgs-unstable package set.
  pkgs = import (builtins.fetchGit {
    url = "https://github.com/NixOS/nixpkgs.git";
    name = "nixpkgs-unstable_01.09.2021";
    rev = "6cc260cfd60f094500b79e279069b499806bf6d8";
    ref = "nixpkgs-unstable";
  }) {
    overlays = [ qchemOvl ];
    config = {
      allowUnfree = true; # For proprietary packages
      qchem-config = {
        # Enables performance tunings for Haswell
        # CPUs and upwards such as AVX2
        optArch = "haswell";
      };
    };
  };
in with pkgs; mkShell {
  buildInputs = [
    # visualisation and building
    avogadro2
    qchem.vmd

    # quantum chemistry codes
    qchem.xtb
    qchem.psi4
    qchem.nwchem
    qchem.multiwfn
    qchem.pysisyphus
  ];
}
