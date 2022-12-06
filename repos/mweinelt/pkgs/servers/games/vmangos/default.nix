{ lib
, llvmPackages_14
, fetchFromGitHub
, cmake
, ace
, git
, libmysqlclient
, openssl
, tbb
}:

llvmPackages_14.stdenv.mkDerivation rec {
  pname = "vmangos";
  version = "unstable-2022-12-03";

  src = fetchFromGitHub {
    owner = "vmangos";
    repo = "core";
    rev = "682e4639396f8470f3dfd70ab06525e041c4b1a6";
    hash = "sha256-CQkpY0CaaSVfhucd1jF8W+D4oYhuXcNjAYBFCc4fJSk=";
  };

  postPatch = ''
    substituteInPlace cmake/revision.h.cmake \
      --replace "@rev_hash@" "${src.rev}"
  '';

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

  postInstall = ''
    cp -Rv ../sql $out/sql
  '';


  meta = with lib; {
    description = "Progressive Vanilla Core aimed at all versions from 1.2 to 1.12";
    homepage = "https://github.com/vmangos/core";
    license = licenses.gpl2;
  };
}
