{ stdenv, fetchurl, pkgconfig, bison, numactl, libxml2
, perl, gfortran, slurm, openssh, hwloc, rdma-core
, infiniband-diags, opensm, zlib
# Compile with slurm as a process manager
, useSlurm ? false
} :

let
  version = "2.2";

in stdenv.mkDerivation {
  name = "mvapich-${version}";

  src = fetchurl {
    url = "http://mvapich.cse.ohio-state.edu/download/mvapich/mv2/mvapich2-${version}.tar.gz";
    sha256 = "0cdi7cxmkfl1zhi0czmzm0mvh98vbgq8nn9y1d1kprixnb16y6kr";
  };

  nativeBuildInputs = [ pkgconfig bison ];
  propagatedBuildInputs = [ numactl rdma-core zlib infiniband-diags opensm ];
  buildInputs = [ numactl libxml2
                  perl gfortran
                  slurm openssh
                  hwloc rdma-core
                  infiniband-diags opensm ];

  configureFlags = stdenv.lib.optionals useSlurm [ "--with-pmi=pmi1" "--with-pm=slurm" ];

  doCheck = true;

  preFixup = ''
    # /tmp/nix-build... ends up in the RPATH, fix it manually
    for entry in $out/bin/mpichversion $out/bin/mpivars; do
      echo "fix rpath: $entry"
      patchelf --set-rpath "$out/lib" $entry
    done
  '';

  enableParallelBuilding = true;

  meta = with stdenv.lib; {
    description = "MPI-3.1 implementation optimized for Infiband transport";
    homepage = http://mvapich.cse.ohio-state.edu;
    license = licenses.bsd3;
    maintainers = [ maintainers.markuskowa ];
    platforms = platforms.linux;
  };
}
