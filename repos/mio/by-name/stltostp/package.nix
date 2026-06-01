{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation rec {
  pname = "stltostp";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "slugdev";
    repo = "stltostp";
    rev = "v${version}";
    sha256 = "1bqr6w5n082nj16cr6wh90n9xxiwaa2v36mmy4v8fqrif1wqf3p2";
  };

  nativeBuildInputs = [ cmake ];

  postPatch = ''
    sed -i 's/float_t/float/g' main.cpp
    sed -i 's/float_t/float/g' StepKernel.h
    sed -i 's/float_t/float/g' StepKernel.cpp
    sed -i '1i#include <cmath>' StepKernel.cpp
    sed -i '1i#include <cstdint>' main.cpp
    sed -i 's/std::string StepKernel::read_line/std::string read_line/g' StepKernel.h
  '';

  meta = with lib; {
    description = "Command line utility to convert stl files to STEP brep files";
    homepage = "https://github.com/slugdev/stltostp";
    license = licenses.mit;
    platforms = platforms.linux ++ platforms.darwin;
    maintainers = [ ];
    mainProgram = "stltostp";
  };
}
