{ stdenv
, fetchFromGitHub
, cmake
, opencl-headers
, ocl-icd
, sd
}:
let
  version = "1.6.0";
in
stdenv.mkDerivation {
  pname = "clblast";
  inherit version;
  src = fetchFromGitHub {
    owner = "CNugteren";
    repo = "CLBlast";
    rev = version;
    hash = "sha256-eRwSfP6p0+9yql7TiXZsExRMcnnBLXXW2hh1JliYU2I=";
  };
  nativeBuildInputs = [ cmake ];
  buildInputs = [ opencl-headers ocl-icd ];
  postPatch = ''
    substituteInPlace clblast.pc.in \
      --replace '$'{prefix}/@CMAKE_INSTALL_INCLUDEDIR@ @CMAKE_INSTALL_FULL_INCLUDEDIR@ \
      --replace '$'{exec_prefix}/@CMAKE_INSTALL_LIBDIR@ @CMAKE_INSTALL_FULL_LIBDIR@
  '';
}
