{
  # nixpkgs sources
    nixpkgs ? { outPath = <nixpkgs>; shortRev = "0000000"; }

  # Override config from ENV
  , config ? {}
  , NixOS-QChem ? { shortRev = "0000000"; }
} :


let
  # options for nixpkgs
  input = {
    overlays = [ (import ./default.nix) ];
    config.allowUnfree = true;
    config.qchem-config = (import ./cfg.nix) config;
  };

  # import package set
  pkgs = (import nixpkgs) input;

  cfg = pkgs.config.qchem-config;

jobs = rec {
  openmpiPkgs = {
    inherit (pkgs.openmpiPkgs)
      cp2k
      hpl
      bagel
      mctdh
      nwchem;
  };

  osu-benchmark = pkgs.openmpiPkgsNoCpp.osu-benchmark;
  extra = {
    inherit (pkgs)
      libcint
      libint2
      libint1
      mkl
      quantum-espresso
      quantum-espresso-mpi
      siesta-mpi
      siesta
      octopus
      gromacsDoubleMpi
      gromacsDouble
      libxsmm
      openblas
      openblasCompat
      spglib;

  };

  scalapack = pkgs.openmpiPkgs.scalapack;

  inherit (pkgs)
    chemps2
    cp2k
    bagel
    bagel-serial
    ergoscf
    fftwOpt
    hwloc-x11
    hpcg
    molcas
    molcas2010
    molden
    molcasUnstable
    mt-dgemm
    nwchem
    octave
    sharcV1
    sharc
    sharc21
    slurm-tools
    stream-benchmark;

  pyscf = pkgs.python3Packages.pyscf;
  pychemps2 = pkgs.python3Packages.pychemps2;
  pyquante = pkgs.python2Packages.pyquante;

  # Packages depending on optimized libs
  deps = {
    python2 = {
      inherit (pkgs.python2Packages)
        numpy
        scipy;
    };

    python3 = {
      inherit (pkgs.python3Packages)
        numpy
        scipy;
    };
  };

  release = {
    tests = {
      inherit (pkgs.qc-tests)
        bagel
        cp2k
        nwchem
        molcas;
    } // pkgs.lib.optionalAttrs (cfg.srcurl != null) {
      inherit (pkgs.qc-tests)
        molpro
        mesa-qc
        qdng;
    };

    tested = with pkgs; releaseTools.aggregate {
      name = "tests";
      constituents = with release; [
        tests.cp2k
        tests.nwchem
        tests.molcas
        molden
      ] ++ lib.optionals (cfg.srcurl != null) [
        tests.molpro
        tests.mesa-qc
        tests.qdng
      ];
    };

    nixexprs = with pkgs; runCommand "nixexprs" {}
      ''
        mkdir -p $out/nixpkgs $out/NixOS-QChem

        cp -r ${nixpkgs}/* $out/nixpkgs
        cp -r ${./.}/* $out/NixOS-QChem

        cp ${./channel.nix} $out/default.nix

        # nixpkgs version
        cp ${nixpkgs}/.version $out/.version
        cp ${nixpkgs}/.version $out/nixpkgs/.version

        cat <<EOF > $out/.revision
        nixpkgs ${nixpkgs.shortRev}
        NixOS-QChem ${NixOS-QChem.shortRev}
        EOF
      '';

    channel = pkgs.releaseTools.channel {
      name = "NixOS-QChem-channel";
      src = release.nixexprs;
      constituents = [ release.tested ];
    };
  };

} // (if cfg.srcurl != null then
  {
    inherit (pkgs)
      gaussview
      qdng
      mesa-qc
      mctdh
      orca
      sharcV1
      vmd;
  }
  else {}
  )
  // (if cfg.licMolpro != null then
  {
    inherit (pkgs)
      molpro
      molpro12
      molpro15
      molpro18
      molpro19;
  }
  else {}
  ) // (if cfg.optpath != null  then
  {
    inherit (pkgs) gaussian;
  }
  else {}
  );

in jobs


