{ stdenv, fetchFromGitHub, cmake, boost, bison, flex }:
stdenv.mkDerivation {
  name = "tchecker-HEAD";

  src = fetchFromGitHub {
    owner = "ticktac-project";
    repo = "tchecker";
    rev = "f5a1a400f8164d094967b0303b298fd1f57be4e3";
    sha256 = "sha256-eyGt41MGMU9LRQcVjho6n9im8Dg5o6PuiEfiA9L5/QE=";
  };

  patchPhase = ''
    substituteInPlace src/CMakeLists.txt --replace "-flto" ""
  '';

  cmakeFlags =
    [ "-DLIBTCHECKER_ENABLE_SHARED=ON" "-DTCK_ENABLE_BUGFIXES_TESTS=OFF" ];

  enableParallelBuilding = true;

  nativeBuildInputs = [ cmake boost bison flex ];
}
