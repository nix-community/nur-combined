{ lib
, llvmPackages_13
, fetchFromGitHub

# build time
, cmake
, git

# runtime
, boost
, libmysqlclient

# version specifics
, flavor
, rev
, hash

, ...
}:

llvmPackages_13.stdenv.mkDerivation rec {
  pname = "cmangos-${flavor}";
  version = builtins.substring 0 6 rev;

  src = fetchFromGitHub {
    owner = "cmangos";
    repo = "mangos-${flavor}";
    inherit rev hash;
  };

  patches = [
    ./0001-CMakeFiles.txt-look-for-dynamically-linked-boost-lib.patch
  ];

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace "set(REVISION_ID \"Git repository not found\")" "set(REVISION_ID \"${rev}\")"
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
