{ lib, stdenv, fetchFromGitHub, cmake, zstd, libdwarf }:
stdenv.mkDerivation rec {
  pname = "cpptrace";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "jeremy-rifkin";
    repo = "cpptrace";
    rev = "v${version}";
    hash = "sha256-zjPxPtq+OQ104sJoeBD3jpMV9gV57FSHEJS4W6SF8GM=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libdwarf zstd ];

  cmakeFlags = [
    "-DCPPTRACE_GET_SYMBOLS_WITH_LIBDWARF=1"
    "-DCPPTRACE_USE_EXTERNAL_LIBDWARF=1"
    "-DCPPTRACE_USE_EXTERNAL_ZSTD=1"
  ];

  meta = with lib; {
    description = "Simple, portable, and self-contained C++ stacktrace library supporting C++11 and greater";
    homepage = "https://github.com/jeremy-rifkin/cpptrace";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with lib.maintainers; [ foolnotion ];
  };
}
