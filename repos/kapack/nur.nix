# If called without explicitly setting the 'pkgs' arg, a pinned nixpkgs version is used by default.
{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/21.05.tar.gz";
    sha256 = "1ckzhh24mgz6jd1xhfgx0i9mijk6xjqxwsshnvq789xsavrmsc36";
  }) {}
, debug ? false
}:

rec {
  # The `lib`, `modules`, and `overlay` names are special
  lib = import ./lib { inherit pkgs; }; # functions
  modules = import ./modules; # NixOS modules
  overlays = import ./overlays; # nixpkgs overlays
  inherit pkgs;

  glibc-batsky = pkgs.glibc.overrideAttrs (attrs: {
    meta.broken = true;
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

  # go_1_14-batsky = if (pkgs ? go_1_14) then
  #   (pkgs.go_1_14.overrideAttrs (attrs: {
  #   src = pkgs.fetchFromGitHub {
  #     owner = "oar-team";
  #     repo = "go_1_14-batsky";
  #     rev = "0119ed47a612226f73a9db56d6572cfab858d59e";
  #     sha256 = "1795xk5r0h6nl7fgjpdwzhmc4rgyz1v4jr6q46cdzp3fjqg345n3";
  #   };
  #   doCheck = false;
  # }))
  #   else
  #   pkgs.callPackage ({}: {meta.broken=true;}) {};

  libpowercap = pkgs.callPackage ./pkgs/libpowercap { };

  haskellPackages = import ./pkgs/haskellPackages { inherit pkgs; };

  batsched-130 = pkgs.callPackage ./pkgs/batsched/batsched130.nix { inherit intervalset loguru redox debug; };
  batsched-140 = pkgs.callPackage ./pkgs/batsched/batsched140.nix { inherit intervalset loguru redox debug; };
  batsched = batsched-140;

  batexpe = pkgs.callPackage ./pkgs/batexpe { };

  batprotocol-cpp = pkgs.callPackage ./pkgs/batprotocol/cpp.nix { inherit flatbuffers debug; };

  batsim-310 = pkgs.callPackage ./pkgs/batsim/batsim310.nix { inherit intervalset redox debug; simgrid = simgrid-324; };
  batsim-400 = pkgs.callPackage ./pkgs/batsim/batsim400.nix { inherit intervalset redox debug; simgrid = simgrid-325light; };
  batsim-410 = pkgs.callPackage ./pkgs/batsim/batsim410.nix { inherit intervalset redox debug; simgrid = simgrid-329light; };
  batsim = batsim-410;
  batsim-docker = pkgs.callPackage ./pkgs/batsim/batsim-docker.nix { inherit batsim; };

  batsky = pkgs.callPackage ./pkgs/batsky { };

  cli11 = pkgs.callPackage ./pkgs/cli11 { };

  cgvg = pkgs.callPackage ./pkgs/cgvg { };

  colmet = pkgs.callPackage ./pkgs/colmet { inherit libpowercap; };

  colmet-rs = pkgs.callPackage ./pkgs/colmet-rs { };

  colmet-collector = pkgs.callPackage ./pkgs/colmet-collector { };

  evalys = pkgs.callPackage ./pkgs/evalys { inherit procset; };

  flatbuffers = pkgs.callPackage ./pkgs/flatbuffers/2.0.nix { };

  melissa = pkgs.callPackage ./pkgs/melissa { };

  go-swagger  = pkgs.callPackage ./pkgs/go-swagger { };

  gcovr = pkgs.callPackage ./pkgs/gcovr/csv.nix { };

  intervalset = pkgs.callPackage ./pkgs/intervalset { };

  kube-batch = pkgs.callPackage ./pkgs/kube-batch { };

  loguru = pkgs.callPackage ./pkgs/loguru { inherit debug; };

  procset = pkgs.callPackage ./pkgs/procset { };

  oxidisched = pkgs.callPackage ./pkgs/oxidisched { };

  pybatsim-320 = pkgs.callPackage ./pkgs/pybatsim/pybatsim320.nix { inherit procset; };
  pybatsim = pybatsim-320;

  redox = pkgs.callPackage ./pkgs/redox { };

  remote_pdb = pkgs.callPackage ./pkgs/remote-pdb { };

  rt-tests = pkgs.callPackage ./pkgs/rt-tests { };
  
  cigri = pkgs.callPackage ./pkgs/cigri { };
	

  oar = pkgs.callPackage ./pkgs/oar { inherit procset pybatsim remote_pdb; };

  oar2 = pkgs.callPackage ./pkgs/oar2 { };

  oar3 = oar;

  rsg-030 = pkgs.callPackage ./pkgs/remote-simgrid/rsg030.nix { inherit debug ; simgrid = simgrid-326; };
  rsg = rsg-030;

  simgrid-324 = pkgs.callPackage ./pkgs/simgrid/simgrid324.nix { inherit debug; };
  simgrid-325 = pkgs.callPackage ./pkgs/simgrid/simgrid325.nix { inherit debug; };
  simgrid-326 = pkgs.callPackage ./pkgs/simgrid/simgrid326.nix { inherit debug; };
  simgrid-327 = pkgs.callPackage ./pkgs/simgrid/simgrid327.nix { inherit debug; };
  simgrid-328 = pkgs.callPackage ./pkgs/simgrid/simgrid328.nix { inherit debug; };
  simgrid-329 = pkgs.callPackage ./pkgs/simgrid/simgrid329.nix { inherit debug; };
  simgrid-325light = simgrid-325.override { minimalBindings = true; withoutBin = true; };
  simgrid-326light = simgrid-326.override { minimalBindings = true; withoutBin = true; };
  simgrid-327light = simgrid-327.override { minimalBindings = true; withoutBin = true; };
  simgrid-328light = simgrid-328.override { minimalBindings = true; withoutBin = true; };
  simgrid-329light = simgrid-329.override { minimalBindings = true; withoutBin = true; };
  simgrid = simgrid-329;
  simgrid-light = simgrid-329light;

  # Setting needed for nixos-19.03 and nixos-19.09
  slurm-bsc-simulator =
    if pkgs ? libmysql
    then pkgs.callPackage ./pkgs/slurm-simulator { libmysqlclient = pkgs.libmysql; }
    else pkgs.callPackage ./pkgs/slurm-simulator { };
  slurm-bsc-simulator-v17 = slurm-bsc-simulator;

  #slurm-bsc-simulator-v14 = slurm-bsc-simulator.override { version="14"; };

  slurm-multiple-slurmd = pkgs.slurm.overrideAttrs (oldAttrs: {
    configureFlags = oldAttrs.configureFlags ++ ["--enable-multiple-slurmd" "--enable-silent-rules"];
    meta.platforms = pkgs.lib.lists.intersectLists pkgs.rdma-core.meta.platforms
      pkgs.ghc.meta.platforms;
  });

  slurm-front-end = pkgs.slurm.overrideAttrs (oldAttrs: {
    configureFlags = [
      "--enable-front-end"
      "--with-lz4=${pkgs.lz4.dev}"
      "--with-zlib=${pkgs.zlib}"
      "--sysconfdir=/etc/slurm"
      "--enable-silent-rules"
    ];
    meta.platforms = pkgs.lib.lists.intersectLists pkgs.rdma-core.meta.platforms
      pkgs.ghc.meta.platforms;
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

  wait-for-it = pkgs.callPackage ./pkgs/wait-for-it { };
}
