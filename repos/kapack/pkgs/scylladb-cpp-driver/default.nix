{ stdenv, lib, fetchFromGitHub, cmake, libuv, openssl, zlib }:

stdenv.mkDerivation rec {
  pname =  "scylladb-cpp-driver";
  version = "2.16.2b";

  src = fetchFromGitHub {
    owner = "scylladb";
    repo = "cpp-driver";
    rev = "2bdfa2b90c2050b56c0572ba039f576fb5f1a922";
    sha256 = "sha256-U/zBMRRnXHDP1HobQOnzDiLWCdstdsv1har6JTYVNEI=";
  };

  buildInputs = [ cmake libuv openssl zlib ];
  cmakeFlags = [ "-DLIBUV_ROOT_DIR=${libuv}" ];

  meta = with lib; {
    homepage = "https://docs.datastax.com/en/developer/cpp-driver";
    description = "DataStax C/C++ Driver for Apache Cassandra® and DataStax Products";
    license = licenses.asl20;
    platforms = platforms.linux;
  };
}
