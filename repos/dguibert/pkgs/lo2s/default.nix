{ stdenv, fetchFromGitHub
, cmake
, boost
, otf2
, binutils
, git
, libbfd
, zlib
, libiberty
, pkgconfig
}:

stdenv.mkDerivation {
  name = "lo2s-1.1.1-8-gee4d8ff";
  src = fetchFromGitHub {
    owner = "tud-zih-energy";
    repo = "lo2s";
    rev = "ee4d8ff";
    sha256 = "0sbd3kwwf882r2zwbbkgybsw46mnggs14pqd7dj1kn65fgw1z4ja";
    fetchSubmodules = true;
    leaveDotGit = true;
  };
  buildInputs = [ cmake (boost.override { enableStatic=true; }) otf2 git libbfd zlib libiberty pkgconfig ];
  meta.broken = true;
}

