{
  stdenv,
  fetchFromGitHub,
  cmake,
  boost,
  libelf,
  elfutils,
  libdwarf,
  libiberty,
  tbb,
}:
stdenv.mkDerivation {
  name = "dyninst-12.0.1";
  src = fetchFromGitHub {
    owner = "dyninst";
    repo = "dyninst";
    rev = "refs/tags/v12.0.1";
    sha256 = "sha256-nL3DQ9+7awbpqYBy8DTiO0o5rSYMW7Hj3tkR7EfDTwY=";
  };
  nativeBuildInputs = [cmake];
  buildInputs = [boost elfutils libelf libdwarf libiberty tbb];
  propagatedBuildInputs = [
    boost
    tbb
    /*
    tbb/concurrent_hash_map.h: No such file or directory
    */
  ];
  postPatch = "patchShebangs .";
  cmakeFlags = [
    "-DBUILD_RTLIB_32=ON"
  ];
}
