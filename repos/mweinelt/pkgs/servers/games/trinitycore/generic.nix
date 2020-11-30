{ llvmPackages_11
, lib
, fetchFromGitHub
, cmake
, libmysqlclient
, git
, boost
, readline
, bzip2
# version specifics
, version
, owner ? "TrinityCore"
, repo ? "TrinityCore"
, rev ? version
, sha256
, ...
}:

llvmPackages_11.stdenv.mkDerivation rec {
  pname = "TrinityCore";
  inherit version;

  src = fetchFromGitHub {
    inherit owner repo rev sha256;
  };

  nativeBuildInputs = [ cmake git ];
  buildInputs = [ libmysqlclient boost readline bzip2 ];

  cmakeFlags = [
    "-DMYSQL_HOME=${libmysqlclient}/lib/mysql"
    "-DMYSQL_INCLUDE_DIR=${libmysqlclient.dev}/include/mysql"
  ];

  meta = with lib; {
    description = "TrinityCore Open Source MMO Framework";
    homepage = "https://www.trinitycore.org";
    license = licenses.gpl2;
  };
}
