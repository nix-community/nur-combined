{ lib, stdenv, fetchFromGitHub, cmake, cpptrace, magic-enum, zstd, libdwarf }:
stdenv.mkDerivation rec {
  pname = "libassert";
  version = "2.1.4";

  src = fetchFromGitHub {
    owner = "jeremy-rifkin";
    repo = "libassert";
    rev = "v${version}";
    hash = "sha256-Zkh6JjJqtOf91U01fpP4hKhhXfH7YGInodG8CZxHHXQ=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ cpptrace magic-enum zstd libdwarf ];

  cmakeFlags = [
    "-DLIBASSERT_USE_EXTERNAL_CPPTRACE=1"
    "-DLIBASSERT_USE_EXTERNAL_MAGIC_ENUM=1"
  ] ++ cpptrace.cmakeFlags;

  meta = with lib; {
    description = "C++ assertion library";
    homepage = "https://github.com/jeremy-rifkin/libassert";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
