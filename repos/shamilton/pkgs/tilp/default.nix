{ lib
, stdenv
, fetchsvn
, cmake
}:

stdenv.mkDerivation rec {
  pname = "tilp";
  version = "unstable";

  src = fetchsvn {
    url = "svn://svn.code.sf.net/p/msieve/code/trunk";
    rev = "";
    hash = "sha256-aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa=";
  };

  postPatch = ''
    sed -i '/string(REPLACE/d' CMakeLists.txt
    substituteInPlace 'CMakeLists.txt' \
      --replace 'CMAKE_INSTALL_LIBDIR_ARCHIND' 'CMAKE_INSTALL_LIBDIR'
    substituteInPlace 'packaging/pkgconfig.pc.in' \
      --replace '@CMAKE_INSTALL_INCLUDEDIR@' \
                'include'
  '';

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Argument Parser for Modern C++";
    license = licenses.mit;
    homepage = "https://github.com/p-ranav/argparse";
    maintainers = [ "Scott Hamilton <sgn.hamilton+nixpkgs@protonmail.com>" ];
    platforms = platforms.linux;
  };
}
