{ lib
, stdenv
, fetchFromGitHub
, cmake
, zlib
}:

stdenv.mkDerivation rec {
  pname = "cnpy";
  version = "unstable-2018-06-01";

  src = fetchFromGitHub {
    owner = "rogersce";
    repo = "cnpy";
    rev = "4e8810b1a8637695171ed346ce68f6984e585ef4";
    hash = "sha256-NMPDpeNoqvqAhwQk4J+TFw+BtNLI4R+CXpzXQ6hB/LU=";
  };
  postPatch = ''
    substituteInPlace CMakeLists.txt --replace 'install(TARGETS "cnpy"' 'install(TARGETS "cnpy" EXPORT "cnpyTargets"'
    cat <<\EOF >> CMakeLists.txt
    include(GNUInstallDirs)
    install(
      EXPORT "cnpyTargets"
      FILE "cnpyConfig.cmake"
      DESTINATION ''${CMAKE_INSTALL_LIBDIR}/cmake/cnpy
      NAMESPACE cnpy::
    )
    EOF
  '';

  nativeBuildInputs = [
    cmake
  ];
  buildInputs = [
    zlib
  ];

  meta = with lib; {
    description = "Library to read/write .npy and .npz files in C/C";
    homepage = "https://github.com/rogersce/cnpy/";
    license = licenses.mit;
    maintainers = with maintainers; [ ];
    platforms = lib.platforms.unix;
  };
}
