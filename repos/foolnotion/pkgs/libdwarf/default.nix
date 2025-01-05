{ lib, stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "libdwarf";
  version = "0.11.1";

  src = fetchFromGitHub {
    owner = "davea42";
    repo = "libdwarf-code";
    rev = "v${version}";
    hash = "sha256-e+NtRzPPyahNcxWPKv4j/EIJdFwTgKCLfjldsBUatk0=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Library for reading DWARF2 and DWARF formats";
    homepage = "https://github.com/davea42/libdwarf-code";
    platforms = lib.platforms.unix;
    license = lib.licenses.lgpl21Plus;
    maintainers = [ lib.maintainers.atry ];
  };
}
