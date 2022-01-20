{ lib
, llvmPackages_13
, fetchFromGitHub
, cmake
, ace
, git
, libmysqlclient
, openssl
, tbb
}:

llvmPackages_13.stdenv.mkDerivation rec {
  pname = "vmangos";
  version = "unstable-2022-01-17";

  src = fetchFromGitHub {
    owner = "vmangos";
    repo = "core";
    rev = "a35daf48d9e27c51fcfe7210dd00130b7a4fc8a7";
    hash = "sha256:0wd8nqznngca087pvy1kbsasxwn46ymwm5k711gd3p1wlbkc2vmv";
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
