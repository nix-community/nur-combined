# If called without explicitly setting the 'pkgs' arg, a pinned nixpkgs version is used by default.
{ pkgs ? import (fetchTarball {
    url = "https://github.com/NixOS/nixpkgs/archive/branch-off-24.11.tar.gz";
    sha256 = "1gx0hihb7kcddv5h0k7dysp2xhf1ny0aalxhjbpj2lmvj7h9g80a";
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

  # Need to switch from 'buildGoPackage' to 'buildGoModule'
  #batexpe = pkgs.callPackage ./pkgs/batexpe { };

  # batsim-410 = pkgs.callPackage ./pkgs/batsim/batsim410.nix { inherit redox debug; simgrid = simgrid-334light; intervalset = intervalsetlight; };
  # batsim-420 = pkgs.callPackage ./pkgs/batsim/batsim420.nix { inherit redox debug; simgrid = simgrid-334light; intervalset = intervalsetlight; };
  # batsim = batsim-420;
  # batsim-docker = pkgs.callPackage ./pkgs/batsim/batsim-docker.nix { inherit batsim; };

  elastisim = pkgs.callPackage ./pkgs/elastisim { };

  batsky = pkgs.callPackage ./pkgs/batsky { };

  cpp-driver = pkgs.callPackage ./pkgs/cpp-driver {};

  scylladb-cpp-driver = pkgs.callPackage ./pkgs/scylladb-cpp-driver {};

  bacnet-stack = pkgs.callPackage ./pkgs/bacnet-stack { };

  alumet = pkgs.callPackage ./pkgs/alumet { };
    
  #dcdb = pkgs.callPackage ./pkgs/dcdb { inherit scylladb-cpp-driver bacnet-stack mosquitto-dcdb; };

  dispath = pkgs.callPackage ./pkgs/dispath { };

  distem = pkgs.callPackage ./pkgs/distem { };

  ear =  pkgs.callPackage ./pkgs/ear { };

  enoslib-ansible = pkgs.callPackage ./pkgs/enoslib-ansible { };
  enoslib = pkgs.callPackage ./pkgs/enoslib { inherit iotlabcli iotlabsshcli distem python-grid5000 enoslib-ansible; };

  evalys = pkgs.callPackage ./pkgs/evalys { inherit procset; };

  execo = pkgs.callPackage ./pkgs/execo { };

  flower = pkgs.callPackage ./pkgs/flower { inherit iterators; };

  iotlabcli = pkgs.callPackage ./pkgs/iotlabcli { };
  iotlabsshcli = pkgs.callPackage ./pkgs/iotlabsshcli { inherit iotlabcli; };

  jFed = pkgs.callPackage ./pkgs/jFed { };

  likwid = pkgs.callPackage ./pkgs/likwid { };

  melissa = pkgs.callPackage ./pkgs/melissa { };
  melissa-heat-pde = pkgs.callPackage ./pkgs/melissa-heat-pde { inherit melissa; };

  mlxp = pkgs.callPackage ./pkgs/mlxp { };

  npb =  pkgs.callPackage ./pkgs/npb { };

  gocov = pkgs.callPackage ./pkgs/gocov { };

  # Need to switch from 'buildGoPackage' to 'buildGoModule'
  #gocovmerge = pkgs.callPackage ./pkgs/gocovmerge { };

  intervalset = pkgs.callPackage ./pkgs/intervalset { };
  intervalsetlight = pkgs.callPackage ./pkgs/intervalset { withoutBoostPropagation = true; };

  iterators = pkgs.callPackage ./pkgs/iterators { };

  # Need to switch from 'buildGoPackage' to 'buildGoModule'
  #kube-batch = pkgs.callPackage ./pkgs/kube-batch { };

  loguru = pkgs.callPackage ./pkgs/loguru { inherit debug; };

  procset = pkgs.callPackage ./pkgs/procset { };

  mosquitto-dcdb = pkgs.callPackage ./pkgs/mosquitto-dcdb {};

  nxc = pkgs.callPackage ./pkgs/nxc { inherit execo; };

  oxidisched = pkgs.callPackage ./pkgs/oxidisched { };

  pybatsim-320 = pkgs.callPackage ./pkgs/pybatsim/pybatsim320.nix { inherit procset; };
  pybatsim-321 = pkgs.callPackage ./pkgs/pybatsim/pybatsim321.nix { inherit procset; };
  pybatsim-core-400 = pkgs.callPackage ./pkgs/pybatsim/core400.nix { inherit procset; };
  pybatsim-functional-400 = pkgs.callPackage ./pkgs/pybatsim/functional400.nix { pybatsim-core = pybatsim-core-400; };
  pybatsim = pybatsim-321;
  pybatsim-core = pybatsim-core-400;
  pybatsim-functional = pybatsim-functional-400;

  python-mip = pkgs.callPackage ./pkgs/python-mip { };

  redox = pkgs.callPackage ./pkgs/redox { };

  remote_pdb = pkgs.callPackage ./pkgs/remote-pdb { };

  cigri = pkgs.callPackage ./pkgs/cigri { };

  oar = pkgs.callPackage ./pkgs/oar { inherit procset pybatsim remote_pdb oar-plugins; };

  oar-plugins = pkgs.callPackage ./pkgs/oar-plugins { inherit procset pybatsim remote_pdb oar; };
  
  oar2 = pkgs.callPackage ./pkgs/oar2 { };

  oar3 = oar;
  
  oar3-plugins = oar-plugins;

  #oar-with-plugins = oar.override { enablePlugins = true; };
  oar-with-plugins = pkgs.callPackage ./pkgs/oar { inherit procset pybatsim remote_pdb oar-plugins; enablePlugins = true; };


  # simgrid-327 = pkgs.callPackage ./pkgs/simgrid/simgrid327.nix { inherit debug; };
  # simgrid-328 = pkgs.callPackage ./pkgs/simgrid/simgrid328.nix { inherit debug; };
  # simgrid-329 = pkgs.callPackage ./pkgs/simgrid/simgrid329.nix { inherit debug; };
  # simgrid-330 = pkgs.callPackage ./pkgs/simgrid/simgrid330.nix { inherit debug; };
  # simgrid-331 = pkgs.callPackage ./pkgs/simgrid/simgrid331.nix { inherit debug; };
  # simgrid-332 = pkgs.callPackage ./pkgs/simgrid/simgrid332.nix { inherit debug; };
  # simgrid-334 = pkgs.callPackage ./pkgs/simgrid/simgrid334.nix { inherit debug; };
  # simgrid-335 = pkgs.callPackage ./pkgs/simgrid/simgrid335.nix { inherit debug; };
  # simgrid-336 = pkgs.callPackage ./pkgs/simgrid/simgrid336.nix { inherit debug; };
  simgrid-400 = pkgs.callPackage ./pkgs/simgrid/simgrid400.nix { inherit debug; };
  # simgrid-327light = simgrid-327.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; };
  # simgrid-328light = simgrid-328.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; };
  # simgrid-329light = simgrid-329.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; };
  # simgrid-330light = simgrid-330.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; };
  # simgrid-331light = simgrid-331.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; };
  # simgrid-332light = simgrid-332.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; };
  # simgrid-334light = simgrid-334.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; };
  # simgrid-335light = simgrid-335.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; };
  # simgrid-336light = simgrid-336.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; modelCheckingSupport = false; };
  simgrid-400light = simgrid-400.override { minimalBindings = true; withoutBin = true; withoutBoostPropagation = true; buildPythonBindings = false; modelCheckingSupport = false; };
  simgrid = simgrid-400;
  simgrid-light = simgrid-400light;

  ssh-known-hosts-edit = pkgs.callPackage ./pkgs/ssh-known-hosts-edit { };
  slices-bi-client = pkgs.callPackage ./pkgs/slices-bi-client { };
  slices-cli = pkgs.callPackage ./pkgs/slices-cli { inherit slices-bi-client ssh-known-hosts-edit; };

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
    meta.broken = true;
  });

  python-grid5000 = pkgs.callPackage ./pkgs/python-grid5000 { };

  starpu = pkgs.callPackage ./pkgs/starpu { };

  # Need to switch from 'buildGoPackage' to 'buildGoModule'
  #yamldiff = pkgs.callPackage ./pkgs/yamldiff { };
}
