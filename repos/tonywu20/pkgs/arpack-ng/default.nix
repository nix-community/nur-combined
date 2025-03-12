{ stdenv, fetchurl, gfortran, cmake, blas, liblapack }:

stdenv.mkDerivation rec {

    version = "3.5.0";
    name = "arpack-ng-${version}";
    
    src = fetchurl {
      url = "https://github.com/opencollab/arpack-ng/archive/${version}.tar.gz";
      sha256 = "0f8jx3fifmj9qdp289zr7r651y1q48k1jya859rqxq62mvis7xsh";
    };

    nativeBuildInputs = [ gfortran cmake ];
    buildInputs = [ blas liblapack ];

    cmakeFlags = [ " -DBUILD_SHARED_LIBS=ON " ];

    meta = {
    	 description = "Library for eigenvalues and eigenvectors";
	 homepage = "https://github.com/opencollab/arpack-ng";
	 license = stdenv.lib.licenses.bsd3;
	 platforms = stdenv.lib.platforms.all;
    };
}
