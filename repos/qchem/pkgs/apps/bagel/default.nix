{ stdenv, lib, fetchFromGitHub, autoconf, automake, libtool
, makeWrapper, openssh
, python, boost, mpi, libxc, blas
, withScalapack ? false
, scalapack
} :

let
  version = "1.2.2";

  blasName = (builtins.parseDrvName blas.name).name;

  mpiName = (builtins.parseDrvName mpi.name).name;
  mpiType = if mpiName == "openmpi" then mpiName
       else if mpiName == "mpich"  then "mvapich"
       else if mpiName == "mvapich"  then mpiName
       else throw "mpi type ${mpiName} not supported";

in stdenv.mkDerivation {
  name = "bagel-${version}" + lib.optionalString (blasName != "openblas") "-${blasName}";

  src = fetchFromGitHub {
    owner = "nubakery";
    repo = "bagel";
    rev = "v${version}";
    sha256 = "184p55dkp49s99h5dpf1ysyc9fsarzx295h7x0id8y0b1ggb883d";
  };

  nativeBuildInputs = [ autoconf automake libtool openssh boost ];
  buildInputs = [ python boost libxc blas mpi ]
                ++ lib.optional withScalapack scalapack;

  #
  # Furthermore, if relativistic calculations fail without MKL,
  # users may consider reconfiguring and recompiling with -DZDOT_RETURN in CXXFLAGS.
  CXXFLAGS="-DNDEBUG -O3 -mavx -DCOMPILE_J_ORB "
           + lib.optionalString (blasName == "openblas") "-lopenblas -DZDOT_RETURN"
           + lib.optionalString (blasName == "mkl") "-L${blas}/lib/intel64";

  LDFLAGS = lib.optionalString (blasName == "mkl") "-L${blas}/lib/intel64";

  BOOST_ROOT=boost;

  configureFlags = with lib; [ "--with-libxc" "--with-boost=${boost}" ]
                   ++ optional ( mpi != null ) "--with-mpi=${mpiType}"
                   ++ optional ( mpi == null ) "--disable-smith"
                   ++ optional ( blasName == "mkl" ) "--enable-mkl"
                   ++ optional ( !withScalapack ) "--disable-scalapack";

  postPatch = ''
    # Fixed upstream
    sed -i '/using namespace std;/i\#include <string.h>' src/util/math/algo.cc
  '';

  preConfigure = ''
    ./autogen.sh
  '';

  enableParallelBuilding = true;

  postInstall = lib.optionalString (mpi != null) ''
    cat << EOF > $out/bin/bagel
    if [ \$# -lt 1 ]; then
    echo
    echo "Usage: $(basename \\$0) [mpirun parameters] <input file>"
    echo
    exit
    fi
    ${mpi}/bin/mpirun \''${@:1:\$#-1} $out/bin/BAGEL \''${@:\$#}
    EOF
    chmod 755 $out/bin/bagel

    ''
    + ''
    # install test jobs
    mkdir -p $out/share/tests
    cp test/* $out/share/tests
  '';

  installCheckPhase = ''
    echo "Running HF test"
    export OMP_NUM_THREADS=1
    export OMPI_MCA_rmaps_base_oversubscribe=1
    export MV2_ENABLE_AFFINITY=0
    # Fix to make mpich run in a sandbox
    export HYDRA_IFACE=lo

    ${if (mpi != null) then "mpirun -np 1 $out/bin/BAGEL test/hf_svp_hf.json > log"
    else "$out/bin/BAGEL test/hf_svp_hf.json > log"}

    echo "Check output"
    grep "SCF iteration converged" log
    grep "99.847790" log
  '';

  doInstallCheck = true;

  doCheck = true;

  passthru = { inherit mpi; };

  meta = with lib; {
    description = "Brilliantly Advanced General Electronic-structure Library";
    homepage = "https://nubakery.org";
    license = licenses.gpl3;
    maintainers = [ maintainers.markuskowa ];
    platforms = [ "x86_64-linux" ];
  };
}
