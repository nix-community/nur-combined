{ lib, stdenv, fetchFromGitHub, cmake, doxygen, boost }:

stdenv.mkDerivation rec {
  pname = "gsl-lite";
  version = "0.40.0";

  src = fetchFromGitHub {
    owner = "gsl-lite";
    repo = "gsl-lite";
    rev = "v${version}";
    hash = "sha256-80ksT8XFn2LLMr63gKGZD/0+FDLnAtFyMpuuSjtoBlk=";
  };

  nativeBuildInputs = [ cmake ];

  meta = with lib; {
    description = "Guidelines Support Library for C++98, C++11 up";
    inherit (src.meta) homepage;
    license = licenses.mit;
    maintainers = [ maintainers.sikmir ];
    platforms = platforms.unix;
  };
}
