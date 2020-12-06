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
  version = "unstable-2020-11-30";

  src = fetchFromGitHub {
    owner = "cmangos";
    repo = pname;
    rev = "553211071970bc02956ef6fac74c31d2f461b7e9";
    sha256 = "0jq6c4hvv8fcclm4q4lhzwaz8bg18nm3hpmcnd1746lqjzhvr9ck";
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
