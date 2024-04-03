{ lib, stdenv, fetchFromGitHub, cmake, cpptrace, magic-enum, zstd, libdwarf }:
stdenv.mkDerivation rec {
  pname = "libassert";
  version = "2.0.1";

  src = fetchFromGitHub {
    owner = "jeremy-rifkin";
    repo = "libassert";
    rev = "v${version}";
    hash = "sha256-HzLeu1LxPdBSZjKfs8Y3kxEHmi5EpYNQb84x5FKd1hE=";
  };

  nativeBuildInputs = [ cmake ];

  buildInputs = [ cpptrace magic-enum zstd libdwarf ];

  cmakeFlags = [
    "-DLIBASSERT_USE_EXTERNAL_CPPTRACE=1"
    "-DLIBASSERT_USE_EXTERNAL_MAGIC_ENUM=1"
  ];

  meta = with lib; {
    description = "Generic header-only C++14 sorting library.";
    homepage = "https://github.com/Morwenn/cpp-sort";
    license = licenses.mit;
    platforms = platforms.all;
    #maintainers = with maintainers; [ foolnotion ];
  };
}
