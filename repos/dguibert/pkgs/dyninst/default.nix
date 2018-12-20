{ stdenv, fetchFromGitHub
, cmake
, boost
, libelf
, libdwarf
, libiberty
}:

stdenv.mkDerivation {
  name = "dyninst-9.2.0";
  src = fetchFromGitHub {
    owner = "dyninst";
    repo = "dyninst";
    rev = "refs/tags/v9.2.0";
    sha256 = "140hpxs5v60cvf92hxa98vyk9fcnn7h2xarhxzwki5yx8d7vgma2";
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [ boost libelf libdwarf libiberty ];
  propagatedBuildInputs = [ boost ];
  postPatch = "patchShebangs .";
  cmakeFlags = [
    "-DBUILD_RTLIB_32=ON"
  ];
}

