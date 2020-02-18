# This file describes your repository contents.
# It should return a set of nix derivations
# and optionally the special attributes `lib`, `modules` and `overlays`.
# It should NOT import <nixpkgs>. Instead, you should take pkgs as an argument.
# Having pkgs default to <nixpkgs> is fine though, and it lets you use short
# commands such as:
#     nix-build -A mypackage

{ pkgs ? import <nixpkgs> {} }:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays

  glibc-batsky = pkgs.glibc.overrideAttrs (attrs: {
    patches = attrs.patches ++ [ ./pkgs/glibc-batsky/clock_gettime.patch
      ./pkgs/glibc-batsky/gettimeofday.patch ];
    postConfigure = ''
      export NIX_CFLAGS_LINK=
      export NIX_LDFLAGS_BEFORE=
      export NIX_DONT_SET_RPATH=1
      unset CFLAGS
      makeFlagsArray+=("bindir=$bin/bin" "sbindir=$bin/sbin" "rootsbindir=$bin/sbin" "--quiet")
    '';
  });
  
  libpowercap = pkgs.callPackage ./pkgs/libpowercap { };

  haskellPackages = import ./pkgs/haskellPackages { inherit pkgs; };
  
  arion = pkgs.callPackage ./pkgs/arion { arion-compose = haskellPackages.arion-compose; };
 
  batsky = pkgs.callPackage ./pkgs/batsky { };

  colmet = pkgs.callPackage ./pkgs/colmet { };
  
  procset = pkgs.callPackage ./pkgs/procset { };
  
  pybatsim = pkgs.callPackage ./pkgs/pybatsim { inherit procset; };

  pytest_flask = pkgs.callPackage ./pkgs/pytest-flask { };

  remote_pdb = pkgs.callPackage ./pkgs/remote-pdb { };

  cigri = pkgs.callPackage ./pkgs/cigri { };
  
  oar = pkgs.callPackage ./pkgs/oar { inherit procset sqlalchemy_utils pytest_flask pybatsim remote_pdb; };

  sqlalchemy_utils = pkgs.callPackage ./pkgs/sqlalchemy-utils { };

  # Setting needed for nixos-19.03 and nixos-19.09
  slurm-bsc-simulator =
    if pkgs ? libmysql
    then pkgs.callPackage ./pkgs/slurm-simulator { libmysqlclient = pkgs.libmysql; }
    else pkgs.callPackage ./pkgs/slurm-simulator { };
  slurm-bsc-simulator-v17 = slurm-bsc-simulator;
  
  #slurm-bsc-simulator-v14 = slurm-bsc-simulator.override { version="14"; };
  
  slurm-multiple-slurmd = pkgs.slurm.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ ["--enable-multiple-slurmd" "--enable-silent-rules"];});
  
  slurm-front-end = pkgs.slurm.overrideAttrs (oldAttrs: {
    configureFlags = [
      "--enable-front-end"
      "--with-lz4=${pkgs.lz4.dev}"
      "--with-zlib=${pkgs.zlib}"
      "--sysconfdir=/etc/slurm"
      "--enable-silent-rules"
    ];
  });

  # bs-slurm = pkgs.replaceDependency {
  #   drv = slurm-multiple-slurmd;
  #   oldDependency = pkgs.glibc;
  #   newDependency = glibc-batsky;
  # };
  
  # fe-slurm = pkgs.replaceDependency {
  #   drv = slurm-front-end;
  #   oldDependency = pkgs.glibc;
  #   newDependency = glibc-batsky;
  # };

  tgz-g5k = pkgs.callPackage ./pkgs/tgz-g5k { };

  wait-for-it = pkgs.callPackage ./pkgs/wait-for-it { };
}

