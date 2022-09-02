{ lib, stdenv, fetchFromGitHub, cmake, gtest }:

stdenv.mkDerivation rec {
  pname = "microjson";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "semlanik";
    repo = "microjson";
    rev = "v${version}";
    hash = "sha256-6kGshpy0CDg/8z3unZvGs0Uh1gglZ7yrIGc9/X+M0i8=";
  };

  postPatch = ''
    substituteInPlace tests/CMakeLists.txt \
      --replace "find_package(microjson CONFIG REQUIRED)" ""
  '';

  nativeBuildInputs = [ cmake gtest ];

  cmakeFlags = [ "-DMICROJSON_MAKE_TESTS=ON" ];

  doCheck = true;

  meta = with lib; {
    description = "Tiny streaming json deserializer";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
