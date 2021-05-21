{ lib, stdenv, fetchurl, pkgconfig, bison, numactl, libxml2
, perl, gfortran, slurm, openssh, hwloc, zlib, makeWrapper
# InfiniBand dependencies
, infiniband-diags, opensm, rdma-core
# OmniPath dependencies
, libpsm2, libfabric
# Compile with slurm as a process manager
, useSlurm ? false
# Network type for MVAPICH2
, network ? "ethernet"
} :

assert builtins.elem network [ "ethernet" "infiniband" "omnipath" ];

stdenv.mkDerivation rec {
  pname = "mvapich";
  version = "2.3.5";

  src = fetchurl {
    url = "http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-${version}.tar.gz";
    sha256 = "130sjr5sv851j87qhxiw0a1wc43v6is07vmyly4im67wqpz6gx7r";
  };

  patches = [
    # glibc >= 2.32 compatability
    ./glibc_signals.patch
  ];


  nativeBuildInputs = [ pkgconfig bison makeWrapper ];
  propagatedBuildInputs = [ numactl rdma-core zlib infiniband-diags opensm ];
  buildInputs = with lib; [
    numactl
    libxml2
    perl
    gfortran
    slurm
    openssh
    hwloc
  ] ++ lists.optionals (network == "infiniband") [ rdma-core infiniband-diags opensm ]
    ++ lists.optionals (network == "omnipath") [ libpsm2 libfabric ]
  ;

  configureFlags = [
    "--with-pm=hydra"
    "--enable-fortran=all"
    "--enable-cxx"
    "--enable-threads=multiple"
    "--enable-hybrid"
    "--enable-shared"
  ] ++ lib.optionals useSlurm [ "--with-pmi=pmi2" "--with-pm=slurm" ]
    ++ lib.optional (network == "ethernet") "--with-device=ch3:sock"
    ++ lib.optionals (network == "infiniband") [ "--with-device=ch3:mrail" "--with-rdma=gen2" ]
    ++ lib.optionals (network == "omnipath") ["--with-device=ch3:psm" "--with-psm2=${libpsm2}"]
  ;

  doCheck = true;

  preFixup = ''
    # /tmp/nix-build... ends up in the RPATH, fix it manually
    for entry in $out/bin/mpichversion $out/bin/mpivars; do
      echo "fix rpath: $entry"
      patchelf --set-rpath "$out/lib" $entry
    done
  '';

  # Make OpenSSH available, which is required for mpirun_rsh.
  # Enables hybrid parallelisation scheme by default.
  postFixup = ''
    for exe in $out/bin/*; do
      wrapProgram $exe\
        --prefix PATH : "${openssh}/bin" \
        --set-default MV2_ENABLE_AFFINITY "0"
    done
  '';

  enableParallelBuilding = true;

  meta = with lib; {
    description = "MPI-3.1 implementation optimized for Infiband transport";
    homepage = http://mvapich.cse.ohio-state.edu;
    license = licenses.bsd3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}
