{ lib
, stdenv
, cmake
, boost
, bison
, flex
, fetchFromGitHub
, perl
, python3
, python3Packages
, zlib
, minisat
, cryptominisat
}:

stdenv.mkDerivation rec {
  pname = "stp";
  version = "unstable-2023-12-13";

  src = fetchFromGitHub {
    owner = "stp";
    repo = "stp";
    rev = "0510509a85b6823278211891cbb274022340fa5c";
    hash = "sha256-pWll+MZJ/WggEL6c67G/FENQoALRi4mBpcq17iQa3EI=";
  };

  buildInputs = [ boost zlib minisat cryptominisat python3 ];
  nativeBuildInputs = [ cmake bison flex perl ];
  preConfigure = ''
    python_install_dir=$out/${python3.sitePackages}
    mkdir -p $python_install_dir
    cmakeFlagsArray=(
      $cmakeFlagsArray
      "-DBUILD_SHARED_LIBS=ON"
      "-DPYTHON_LIB_INSTALL_DIR=$python_install_dir"
    )
  '';

  meta = with lib; {
    description = "Simple Theorem Prover";
    homepage = "https://github.com/stp/stp";
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
    license = licenses.mit;
  };
}
