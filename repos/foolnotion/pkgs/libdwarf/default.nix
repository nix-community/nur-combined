{ lib, stdenv, fetchFromGitHub, cmake }:
stdenv.mkDerivation rec {
  pname = "libdwarf";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "davea42";
    repo = "libdwarf-code";
    rev = "v${version}";
    hash = "sha256-SsFg+7zGBEGxDSzfiIP5bxdttlBkhEiEQWaU12hINas=";
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
