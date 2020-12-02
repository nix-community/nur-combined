{ lib
, llvmPackages_11
, fetchFromGitHub
, cmake
, ace
, git
, libmysqlclient
, openssl
, tbb
}:

llvmPackages_11.stdenv.mkDerivation rec {
  pname = "vmangos";
  version = "unstable-2020-11-30";

  src = fetchFromGitHub {
    owner = "vmangos";
    repo = "core";
    rev = "bd974eb24f4899f73b6a7e63a74ba057f649bd79";
    sha256 = "124dvalsw7iy13042dfjmjzcrwkg18z5q95h9hp9njf0d0l3khgd";
  };

  nativeBuildInputs = [ cmake git ];
  buildInputs = [ ace libmysqlclient openssl.dev tbb ];

  cmakeFlags = [
    "-DMYSQL_HOME=${libmysqlclient}/lib/mysql"
    "-DMYSQL_INCLUDE_DIR=${libmysqlclient.dev}/include/mysql"
    "-DOPENSSL_LIBRARIES_DIR=${openssl}/lib/openssl"
    "-DOPENSSL_INCLUDE_DIR=${openssl.dev}/include/openssl"
    "-DUSE_LIBCURL=1"
    "-DUSE_EXTRACTORS=1"
  ];

  meta = with lib; {
    description = "Progressive Vanilla Core aimed at all versions from 1.2 to 1.12";
    homepage = "https://github.com/vmangos/core";
    license = licenses.gpl2;
  };
}
