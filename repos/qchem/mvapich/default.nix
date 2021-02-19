{ lib, stdenv, fetchurl, pkgconfig, bison, numactl, libxml2
, perl, gfortran, slurm, openssh, hwloc, rdma-core
, infiniband-diags, opensm, zlib
# Compile with slurm as a process manager
, useSlurm ? false
} :

let
  version = "2.3.5";

in stdenv.mkDerivation {
  name = "mvapich-${version}";

  src = fetchurl {
    url = "http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-${version}.tar.gz";
    sha256 = "130sjr5sv851j87qhxiw0a1wc43v6is07vmyly4im67wqpz6gx7r";
  };

  patches = [
    # glibc >= 2.32 compatability
    ./glibc_signals.patch
  ];


  nativeBuildInputs = [ pkgconfig bison ];
  propagatedBuildInputs = [ numactl rdma-core zlib infiniband-diags opensm ];
  buildInputs = [ numactl libxml2
                  perl gfortran
                  slurm openssh
                  hwloc rdma-core
                  infiniband-diags opensm ];

  configureFlags = lib.optionals useSlurm [ "--with-pmi=pmi1" "--with-pm=slurm" ];

  doCheck = true;

  preFixup = ''
    # /tmp/nix-build... ends up in the RPATH, fix it manually
    for entry in $out/bin/mpichversion $out/bin/mpivars; do
      echo "fix rpath: $entry"
      patchelf --set-rpath "$out/lib" $entry
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
