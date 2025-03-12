{ stdenv, openblas, fetchurl, perl, libxc, libtool, python, boost, openssh, autoconf, openmpi, automake }:

stdenv.mkDerivation rec{
    version = "1.1.1";
    name = "bagel";
  
    src = fetchurl {
      url = "https://github.com/nubakery/bagel/archive/v1.1.1.tar.gz";
      sha256 = "60d46496c25d18698acf67f39ca7150d0c6daf49944a8e47cf0c10a0e31d245f";
    };
    
    #unpackPhase = ''
    #  mkdir ${name}-${version}
    #  tar -C ${name} -xzf $src 
    #'';
      
    nativeBuildInputs = [ autoconf automake libtool openssh boost ];
    buildInputs = [ openblas python boost openblas openmpi ];

  #
  # Furthermore, if relativistic calculations fail without MKL,
  # users may consider reconfiguring and recompiling with -DZDOT_RETURN in CXXFLAGS.
  CXXFLAGS="-DNDEBUG -O3 -mavx -DCOMPILE_J_ORB -lopenblas -DZDOT_RETURN";

  #preConfigure = ''
  #    libtoolize
  #    aclocal
  #    autoconf
  #    autoheader
  #    automake -a
  #'';

  BOOST_ROOT=boost;

  configureFlags = [ "--with-mpi=openmpi" "--disable-scalapack" "--with-boost=${boost}" ];

  enableParallelBuilding = true;

  postPatch = ''
    # Fixed upstream
    sed -i '/using namespace std;/i\#include <string.h>' src/util/math/algo.cc
  '';

  preConfigure = ''
    ./autogen.sh
  '';
 

  meta = {
    homepage = "https://nubakery.org/index.html";
    description = "BAGEL is a parallel electronic-structure program licensed under the GNU General Public License.";
    broken = true ; # not really, but compilation is too long for the CI
  };
}  

