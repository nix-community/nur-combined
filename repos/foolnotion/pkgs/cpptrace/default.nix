{ lib, stdenv, fetchFromGitHub, cmake, zstd, libdwarf }:
stdenv.mkDerivation rec {
  pname = "cpptrace";
  version = "0.7.5";

  src = fetchFromGitHub {
    owner = "jeremy-rifkin";
    repo = "cpptrace";
    rev = "v${version}";
    hash = "sha256-2rDyH9vo47tbqqZrTupAOrMySj4IGKeWX8HBTGjFf+g=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ libdwarf zstd ];

  cmakeFlags = [
    "-DCPPTRACE_GET_SYMBOLS_WITH_LIBDWARF=1"
    "-DCPPTRACE_USE_EXTERNAL_LIBDWARF=1"
    "-DCPPTRACE_USE_EXTERNAL_ZSTD=1"
  ];

  meta = with lib; {
    description = "Simple, portable, and self-contained C++ stacktrace library";
    homepage = "https://github.com/jeremy-rifkin/cpptrace";
    license = licenses.mit;
    platforms = platforms.all;
    maintainers = with lib.maintainers; [ foolnotion ];
  };
}
