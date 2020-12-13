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
  version = "unstable-2020-12-13";

  src = fetchFromGitHub {
    owner = "vmangos";
    repo = "core";
    rev = "241c75348882ac28e6612015b7556ca70c4b8031";
    sha256 = "0qcs2niaa2nrgkzry1c6spaixds0iwycxbllhgj0xy5ig16fzg4a";
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
