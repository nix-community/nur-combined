{ lib
, llvmPackages_11
, fetchFromGitHub
, cmake
, boost
, git
, libmysqlclient
}:

llvmPackages_11.stdenv.mkDerivation rec {
  pname = "mangos-tbc";
  version = "unstable-2020-12-13";

  src = fetchFromGitHub {
    owner = "cmangos";
    repo = pname;
    rev = "ed2cf172a13909ed47cd49269096347687eb8747";
    sha256 = "1w993qc8zfpii9ahmlv4ldhxf1mwmvcjfja3j7kd26v62i4qkapr";
  };

  patches = [
    ./0001-CMakeFiles.txt-look-for-dynamically-linked-boost-lib.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(REVISION_ID \"Git repository not found\")" "set(REVISION_ID \"${src.rev}\")"
  '';

  nativeBuildInputs = [ cmake git ];
  buildInputs = [ boost libmysqlclient ];

  cmakeFlags = [
    "-DBOOST_LIBRARYDIR=${boost.out}/lib/boost"
    "-DBOOST_INCLUDEDIR=${boost.dev}/include/boost"
    "-DMYSQL_HOME=${libmysqlclient}/lib/mysql"
    "-DMYSQL_INCLUDE_DIR=${libmysqlclient.dev}/include/mysql"
    "-DBUILD_EXTRACTORS=ON"
  ];

  meta = with lib; {
    description = "Continued Massive Network Game Object Server";
    homepage = "https://cmangos.net";
    license = licenses.gpl2;
  };
}
